package com.example.saveNet.dto;

import lombok.Data;

@Data
public class AedInfoDto {
    private String org;           // 설치 기관명
    private String buildPlace;    // AED 설치 위치 (예: 101동 경비실)
    private String buildAddress;  // 전체 주소
    private String manager;       // 담당자 이름
    private String managerTel;    // 담당자 전화번호
    private String model;         // AED 모델명
    private double wgs84Lat;      // 위도
    private double wgs84Lon;      // 경도
}
