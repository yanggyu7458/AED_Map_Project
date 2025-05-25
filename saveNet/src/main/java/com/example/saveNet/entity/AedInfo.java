package com.example.saveNet.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "aed_info")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AedInfo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "org_name")
    private String orgName;

    @Column(name = "build_place")
    private String buildPlace;

    @Column(name = "build_address")
    private String buildAddress;

    @Column(name = "manager")
    private String manager;

    @Column(name = "manager_tel")
    private String managerTel;

    @Column(name = "model")
    private String model;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;
}
