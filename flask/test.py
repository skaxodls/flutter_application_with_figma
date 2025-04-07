import torch
import cv2
import timm
import os
import numpy as np
import re
import matplotlib.pyplot as plt
from ultralytics import YOLO
from torchvision import transforms
from PIL import Image
from torch import nn

# ✅ 모델 경로 설정
yolo_model_path = r"C:\Users\n3225\OneDrive\Desktop\model_test\best.pt"
hybrid_model_path = r"C:\Users\n3225\OneDrive\Desktop\fish_go_app_with_flask\flutter_application_with_figma\flask\models\hybrid_fish_classifier.pth"
# ✅ 단일 이미지 경로 설정
image_path = r"C:\Users\n3225\OneDrive\Desktop\model_test\fishing_test_dataset\gamseongdom(11)(10).jpg"

# ✅ YOLOv8 모델 로드 (물고기 탐지)
yolo_model = YOLO(yolo_model_path)


# ✅ HybridFishClassifier 정의 (CNN + DeiT)
class HybridFishClassifier(nn.Module):
    def __init__(self, num_classes=13):
        super().__init__()
        # CNN 백본 (EfficientNet)
        self.cnn = timm.create_model('efficientnet_b0', pretrained=False, num_classes=0)
        self.cnn_out_dim = self.cnn.num_features  # CNN 출력 특징 차원

        # DeiT 백본
        self.transformer = timm.create_model('deit_small_patch16_224', pretrained=False, num_classes=0)
        self.transformer_out_dim = 384  # DeiT-Small의 임베딩 차원

        # 최종 분류기 (CNN + Transformer 특징 결합)
        self.fc = nn.Linear(self.cnn_out_dim + self.transformer_out_dim, num_classes)

    def forward(self, x):
        cnn_feat = self.cnn(x)  # CNN 특징 추출
        trans_feat = self.transformer(x)  # Transformer 특징 추출
        combined = torch.cat((cnn_feat, trans_feat), dim=1)  # 특징 결합
        return self.fc(combined)  # 최종 분류

# ✅ Hybrid 모델 로드
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
hybrid_model = HybridFishClassifier(num_classes=5)
hybrid_model.load_state_dict(torch.load(hybrid_model_path, map_location=device))
hybrid_model.to(device)
hybrid_model.eval()

# ✅ 클래스 리스트 (5개 물고기 종)
class_names = [
    "gamseongdom",
    "jeomnongeo",
    "neobchinongeo", "nongeo", "saenunchi"
]
class_to_idx = {cls: idx for idx, cls in enumerate(class_names)}
idx_to_class = {v: k for k, v in class_to_idx.items()}

# ✅ 이미지 전처리 (Hybrid 모델 입력용)
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# ✅ 이미지 처리 및 분류 함수 (단일 이미지 처리)
def detect_and_classify(image_path):
    # 1. 이미지 로드
    img = cv2.imread(image_path)
    if img is None:
        print(f"❌ 이미지 로드 실패: {image_path}")
        return None
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # 2. YOLOv8을 사용하여 물고기 탐지
    results = yolo_model(img_rgb)
    if len(results[0].boxes) == 0:
        print(f"❌ {os.path.basename(image_path)}: 물고기 탐지 실패")
        return None

    # 3. 가장 확률이 높은 바운딩 박스 선택
    best_box = max(results[0].boxes, key=lambda b: b.conf)
    x1, y1, x2, y2 = map(int, best_box.xyxy[0].tolist())

    # 4. 이미지 크롭
    cropped_fish = img_rgb[y1:y2, x1:x2]
    cropped_fish_pil = Image.fromarray(cropped_fish)

    # 5. Hybrid 모델로 물고기 종 분류
    input_tensor = transform(cropped_fish_pil).unsqueeze(0).to(device)
    with torch.no_grad():
        outputs = hybrid_model(input_tensor)
        _, pred_idx = torch.max(outputs, 1)
    predicted_class = class_names[pred_idx.item()]

    # 6. 정답 레이블 추출 (파일명 기반, 없으면 'Unknown')
    true_label = "Unknown"
    match = re.match(r"(.+?)\s*\(\d+\)", os.path.basename(image_path))
    if match:
        true_label = match.group(1)

    return img_rgb, cropped_fish_pil, true_label, predicted_class, (x1, y1, x2, y2)

# ✅ 시각화 함수 (탐지된 이미지 출력)
def visualize_detection(image, cropped_fish, true_label, predicted_class, bbox, image_path):
    x1, y1, x2, y2 = bbox
    is_correct = true_label == predicted_class
    text_color = (0, 255, 0) if is_correct else (255, 0, 0)  # 정답: 초록, 오답: 빨강

    # 원본 이미지에 바운딩 박스 및 정답/예측 클래스명 표시
    image_with_bbox = image.copy()
    cv2.rectangle(image_with_bbox, (x1, y1), (x2, y2), text_color, 2)
    cv2.putText(image_with_bbox, f"GT: {true_label}", (x1, y1 - 20),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
    cv2.putText(image_with_bbox, f"Pred: {predicted_class}", (x1, y1 - 40),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, text_color, 2)

    # 시각화
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))
    axes[0].imshow(cv2.cvtColor(image_with_bbox, cv2.COLOR_BGR2RGB))
    axes[0].set_title("Detected Fish")
    axes[0].axis("off")
    axes[1].imshow(cropped_fish)
    axes[1].set_title(f"GT: {true_label}\nPred: {predicted_class}")
    axes[1].axis("off")
    plt.show()

# ✅ 단일 이미지 처리 및 결과 출력
result = detect_and_classify(image_path)
if result is not None:
    img_rgb, cropped_fish, true_label, predicted_class, bbox = result
    print(f"Ground Truth: {true_label}, Predicted: {predicted_class}")
    visualize_detection(img_rgb, cropped_fish, true_label, predicted_class, bbox, image_path)
