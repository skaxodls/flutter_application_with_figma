import pandas as pd

# 엑셀 파일 경로 설정 (raw string 사용)
excel_file = r"C:\Users\n3225\OneDrive\Desktop\캡디2\통계청 행정구역코드 - sido_sgg_emd_master.xlsx"

# 엑셀 파일 읽기
df = pd.read_excel(excel_file)

# 결측치 제거 후, sido_nm과 sgg5_nm 결합하여 고유한 지역명 생성
combined_regions = df[['sido_nm', 'sgg5_nm']].dropna().apply(
    lambda row: f"{row['sido_nm']} {row['sgg5_nm']}", axis=1
).unique()

# 문자열 길이가 긴 순으로 정렬하면, 더 구체적인 지역명이 먼저 매칭됩니다.
combined_regions = sorted(combined_regions, key=lambda x: len(x), reverse=True)

def classify_address(address: str):
    """
    주어진 주소 문자열에서 sido_nm과 sgg5_nm이 결합된 지역명이 포함되어 있는지 확인하여 반환합니다.
    만약 해당하는 지역이 없으면 None을 반환합니다.
    """
    for region in combined_regions:
        if region in address:
            return region
    return None
