import cv2
import torch
import torch.nn.functional as F
import timm
from ultralytics import YOLO
from PIL import Image
from torch import nn
from torchvision import transforms
import numpy as np
import re
import matplotlib.pyplot as plt
from flask import current_app as app

# ✅ 모델 경로 설정
yolo_model_path = r"C:\Users\n3225\OneDrive\Desktop\model_test\best.pt"
hybrid_model_path = r"C:\Users\n3225\OneDrive\Desktop\fish_go_app_with_flask\flutter_application_with_figma\flask\models\hybrid_fish_classifier.pth"

# ✅ YOLOv8 탐지 모델 로드
yolo_model = YOLO(yolo_model_path)
print("✅ YOLOv8 모델 로드 성공!")

# ✅ HybridFishClassifier 모델 정의
class HybridFishClassifier(nn.Module):
    def __init__(self, num_classes=5):
        super().__init__()
        self.cnn = timm.create_model('efficientnet_b0', pretrained=False, num_classes=0)
        self.cnn_out_dim = self.cnn.num_features

        self.transformer = timm.create_model('deit_small_patch16_224', pretrained=False, num_classes=0)
        self.transformer_out_dim = 384  # DeiT-Small의 출력 차원

        self.fc = nn.Linear(self.cnn_out_dim + self.transformer_out_dim, num_classes)

    def forward(self, x):
        cnn_feat = self.cnn(x)
        trans_feat = self.transformer(x)
        combined = torch.cat((cnn_feat, trans_feat), dim=1)
        return self.fc(combined)

# ✅ HybridFishClassifier 모델 로드
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
hybrid_model = HybridFishClassifier(num_classes=5)
hybrid_model.load_state_dict(torch.load(hybrid_model_path, map_location=device))
hybrid_model.to(device)
hybrid_model.eval()
print("✅ HybridFishClassifier 모델 로드 성공!")

# ✅ 클래스 리스트 (5개 물고기 종)
class_names = ["gamseongdom", "jeomnongeo", "neobchinongeo", "nongeo", "saenunchi"]

# ✅ 이미지 전처리 변환
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])



def detect_and_classify(image):
    """
    YOLOv8로 물고기 탐지 후 HybridFishClassifier로 분류.
    파일 이름에서 Ground Truth를 추출하여 시각화에 반영.
    """
    # 파일명에서 GT 추출 (예: "gamseongdom(10)(2).jpg" -> "gamseongdom")
    filename = getattr(image, 'filename', 'Unknown.jpg')
    true_label = "Unknown"
    match = re.match(r"(.+?)\s*\(\d+\)", filename)
    if match:
        true_label = match.group(1)

    # PIL을 사용하여 파일 객체에서 이미지 로드 (원본 이미지 변형 최소화)
    try:
        pil_image = Image.open(image).convert("RGB")
    except Exception:
        return {"error": "Invalid image"}
    
    # PIL 이미지 -> NumPy 배열 (RGB)
    img_rgb = np.array(pil_image)

    # 🔹 YOLOv8을 사용하여 물고기 탐지
    results = yolo_model(img_rgb)
    if len(results[0].boxes) == 0:
        return {"error": "No fish detected"}

    # 🔹 가장 확률이 높은 바운딩 박스 선택
    best_box = max(results[0].boxes, key=lambda b: b.conf)
    x1, y1, x2, y2 = map(int, best_box.xyxy[0].tolist())

    # 🔹 이미지 크롭 (주의: OpenCV 형태인 BGR을 쓰지 않고, 현재는 RGB NumPy 상태)
    #    시각화 함수에서는 OpenCV 함수를 쓰므로, BGR 변환이 필요
    #    그러나 여기서 img_rgb는 이미 RGB이므로, 아래서 시각화 전 변환해줍니다.
    cropped_fish = img_rgb[y1:y2, x1:x2]

    # 🔹 Hybrid 모델로 물고기 종 분류
    cropped_fish_pil = Image.fromarray(cropped_fish)
    input_tensor = transform(cropped_fish_pil).unsqueeze(0).to(device)
    with torch.no_grad():
        outputs = hybrid_model(input_tensor)
        probabilities = F.softmax(outputs, dim=1)
        confidence, pred_idx = torch.max(probabilities, 1)

    predicted_class = class_names[pred_idx.item()]
    confidence_score = confidence.item() * 100  # 퍼센트 변환

    # 터미널에 결과 출력
    print(f"\n🎯 **분류 결과** 🎯")
    print(f"🔹 Ground Truth (from filename): {true_label}")
    print(f"🔹 예측된 물고기 종: {predicted_class}")
    print(f"🔹 신뢰도(Confidence): {confidence_score:.2f}%\n")



    return {"predicted_class": predicted_class, "confidence": confidence_score}
