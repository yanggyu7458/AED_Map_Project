package com.example.saveNet.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.saveNet.service.AedOpenApiService;

@RestController
@RequestMapping("/api/load")
public class ForAedDataLoadController {
    
    private final AedOpenApiService aedOpenApiService;

    public ForAedDataLoadController(AedOpenApiService aedOpenApiService) {
        this.aedOpenApiService = aedOpenApiService;
    }

    @GetMapping
    public String loadAedData() {
        aedOpenApiService.fetchAndSaveAedData();
        return "AED 데이터 저장 완료!";
    }
}
