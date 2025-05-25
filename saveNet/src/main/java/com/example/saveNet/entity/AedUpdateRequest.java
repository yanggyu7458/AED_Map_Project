package com.example.saveNet.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "aed_update_request")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AedUpdateRequest {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long originalAedId;
    private String photoFileName;

    private String orgName;
    private String buildPlace;
    private String buildAddress;
    private String manager;
    private String managerTel;
    private String model;

    private Double latitude;
    private Double longitude;

    private LocalDateTime requestedAt = LocalDateTime.now();
}
