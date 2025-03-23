import cv2
import torch
import torch.nn.functional as F
import timm
from ultralytics import YOLO
from PIL import Image
from torch import nn
from torchvision import transforms
import numpy as np
import logging
from flask import current_app as app

# ✅ 모델 경로 설정
yolo_model_path = r"C:\Users\n3225\OneDrive\Desktop\model_test\best.pt"
hybrid_model_path = r"C:\Users\n3225\pycharm_source_code\python\imageprocessing\.venv\Scripts\capstone\hybrid_fish_classifier.pth"

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
    """YOLOv8로 물고기 탐지 후 HybridFishClassifier로 분류"""
    
    # OpenCV로 이미지 로드
    img_array = np.frombuffer(image.read(), np.uint8)
    img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
    
    if img is None:
        return {"error": "Invalid image"}

    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # 🔹 YOLOv8을 사용하여 물고기 탐지
    results = yolo_model(img_rgb)

    if len(results[0].boxes) == 0:
        return {"error": "No fish detected"}

    # 🔹 가장 확률이 높은 바운딩 박스 선택
    best_box = max(results[0].boxes, key=lambda b: b.conf)
    x1, y1, x2, y2 = map(int, best_box.xyxy[0].tolist())

    # 🔹 이미지 크롭
    cropped_fish = img_rgb[y1:y2, x1:x2]
    cropped_fish_pil = Image.fromarray(cropped_fish)

    # 🔹 Hybrid 모델로 물고기 종 분류
    input_tensor = transform(cropped_fish_pil).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = hybrid_model(input_tensor)
        probabilities = F.softmax(outputs, dim=1)  # 확률 변환
        confidence, pred_idx = torch.max(probabilities, 1)  # 가장 높은 확률과 클래스 인덱스 가져오기

    # ✅ 예측된 클래스 및 신뢰도 계산
    predicted_class = class_names[pred_idx.item()]
    confidence_score = confidence.item() * 100  # 퍼센트(%) 변환

    # ✅ 터미널에서도 결과 출력
    print(f"\n🎯 **분류 결과** 🎯")
    print(f"🔹 예측된 물고기 종: {predicted_class}")
    print(f"🔹 신뢰도(Confidence): {confidence_score:.2f}%\n")

    return {"predicted_class": predicted_class, "confidence": confidence_score}
