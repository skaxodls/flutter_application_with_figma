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
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from torch import nn

# ✅ 모델 경로 설정
yolo_model_path = r"C:\Users\n3225\OneDrive\Desktop\model_test\best.pt"
hybrid_model_path = r"C:\Users\n3225\pycharm_source_code\python\imageprocessing\.venv\Scripts\capstone\hybrid_fish_classifier.pth"
image_folder = r"C:\Users\n3225\OneDrive\Desktop\model_test\fishing_test_dataset"

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

# ✅ 성능 평가를 위한 리스트
y_true = []
y_pred = []
detection_results = []  # 이미지 시각화를 위해 결과 저장

# ✅ 이미지 처리 및 분류 함수 (결과 저장)
def detect_and_classify(image_path):
    # 🔹 1. 이미지 로드
    img = cv2.imread(image_path)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # 🔹 2. YOLOv8을 사용하여 물고기 탐지
    results = yolo_model(img_rgb)

    if len(results[0].boxes) == 0:
        print(f"❌ {os.path.basename(image_path)}: 물고기 탐지 실패")
        return None, None, None

    # 🔹 3. 가장 확률이 높은 바운딩 박스 선택
    best_box = max(results[0].boxes, key=lambda b: b.conf)
    x1, y1, x2, y2 = map(int, best_box.xyxy[0].tolist())  # 바운딩 박스 좌표

    # 🔹 4. 이미지 크롭
    cropped_fish = img_rgb[y1:y2, x1:x2]
    cropped_fish_pil = Image.fromarray(cropped_fish)

    # 🔹 5. Hybrid 모델로 물고기 종 분류
    input_tensor = transform(cropped_fish_pil).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = hybrid_model(input_tensor)
        _, pred_idx = torch.max(outputs, 1)

    predicted_class = class_names[pred_idx.item()]

    # 🔹 6. 정답 레이블 추출 (파일명 기반)
    true_label = "Unknown"
    match = re.match(r"(.+?)\s*\(\d+\)", os.path.basename(image_path))
    if match:
        true_label = match.group(1)
        if true_label in class_to_idx:
            true_idx = class_to_idx[true_label]  # 정답 인덱스 변환
            y_true.append(true_idx)
            y_pred.append(pred_idx.item())

    # 🔹 7. 결과 저장 (시각화를 위해)
    detection_results.append((img_rgb, cropped_fish_pil, true_label, predicted_class, (x1, y1, x2, y2), image_path))

# ✅ 이미지 폴더 내 모든 이미지 처리 (예측 수행)
for file in os.listdir(image_folder):
    if file.endswith(('.jpg', '.png', '.jpeg')):
        image_path = os.path.join(image_folder, file)
        detect_and_classify(image_path)

# ✅ 성능 지표 출력 (예측 후)
if y_true and y_pred:
    print("\n🎯 **성능 평가 결과** 🎯")
    accuracy = accuracy_score(y_true, y_pred)
    print(f"✅ 정확도: {accuracy * 100:.2f}%")
    print("\n📊 **분류 보고서** 📊")
    print(classification_report(y_true, y_pred, target_names=class_names))
    print("\n🔹 **혼동 행렬** 🔹")
    print(confusion_matrix(y_true, y_pred))

# ✅ 시각화 함수 (탐지된 이미지 출력)
def visualize_detection(image, cropped_fish, true_label, predicted_class, bbox, image_path):
    """탐지된 물고기와 분류 결과를 시각화"""
    x1, y1, x2, y2 = bbox
    is_correct = true_label == predicted_class
    text_color = (0, 255, 0) if is_correct else (255, 0, 0)  # ✅ 정답: 초록 / 오답: 빨강

    # 원본 이미지에 바운딩 박스 및 정답/예측 클래스명 표시
    image_with_bbox = image.copy()
    cv2.rectangle(image_with_bbox, (x1, y1), (x2, y2), text_color, 2)
    cv2.putText(image_with_bbox, f"GT: {true_label}", (x1, y1 - 20),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
    cv2.putText(image_with_bbox, f"Pred: {predicted_class}", (x1, y1 - 40),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, text_color, 2)

    # 시각화
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))

    # 원본 이미지 출력
    axes[0].imshow(cv2.cvtColor(image_with_bbox, cv2.COLOR_BGR2RGB))
    axes[0].set_title("Detected Fish")
    axes[0].axis("off")

    # 크롭된 이미지 출력
    if cropped_fish is not None:
        axes[1].imshow(cropped_fish)
        axes[1].set_title(f"GT: {true_label}\nPred: {predicted_class}", color=("green" if is_correct else "red"))
        axes[1].axis("off")

    # 결과 저장
    result_dir = os.path.join(os.path.dirname(image_path), "results")
    os.makedirs(result_dir, exist_ok=True)
    plt.savefig(os.path.join(result_dir, os.path.basename(image_path)))
    plt.show()

# ✅ 개별 이미지 결과 시각화
for result in detection_results:
    visualize_detection(*result)
