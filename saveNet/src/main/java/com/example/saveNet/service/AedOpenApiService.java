package com.example.saveNet.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.saveNet.dto.AedApiResponse;
import com.example.saveNet.dto.AedInfoDto;
import com.example.saveNet.entity.AedInfo;
import com.example.saveNet.repository.AedInfoRepository;

@Service
public class AedOpenApiService {
    
    private final AedInfoRepository aedInfoRepository;

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${aed.api.key}")
    private String serviceKey;

    public AedOpenApiService(AedInfoRepository aedInfoRepository) {
        this.aedInfoRepository = aedInfoRepository;
    }

    public void fetchAndSaveAedData() {
        int page = 1;
        int numOfRows = 1000;
        int totalCount = 1; 

        while ((page - 1) * numOfRows < totalCount) {
            String url = "https://apis.data.go.kr/B552657/AEDInfoInqireService/getAedLcinfoInqire"
                    + "?serviceKey=" + serviceKey
                    + "&pageNo=" + page
                    + "&numOfRows=" + numOfRows
                    + "&_type=json";

            AedApiResponse result = restTemplate.getForObject(url, AedApiResponse.class);

            if (result == null || result.getResponse() == null) {
                System.out.println("응답이 비어있습니다. page=" + page);
                break;
            }

            List<AedInfoDto> items = result.getResponse().getBody().getItems().getItem();
            totalCount = result.getResponse().getBody().getTotalCount();

            System.out.println("page " + page + " 수집 중 (" + items.size() + "건)");

            for (AedInfoDto dto : items) {
                if (dto.getWgs84Lat() == 0 || dto.getWgs84Lon() == 0 || dto.getOrg() == null) {
                    continue;
                }

                if (aedInfoRepository.existsByOrgNameAndBuildPlace(dto.getOrg(), dto.getBuildPlace())) continue;

                AedInfo aed = AedInfo.builder()
                        .orgName(dto.getOrg())
                        .buildPlace(dto.getBuildPlace())
                        .buildAddress(dto.getBuildAddress())
                        .manager(dto.getManager())
                        .managerTel(dto.getManagerTel())
                        .model(dto.getModel())
                        .latitude(dto.getWgs84Lat())
                        .longitude(dto.getWgs84Lon())
                        .build();

                aedInfoRepository.save(aed);
            }

            page++;
        }

        System.out.println("전체 AED 수집 완료!");
    }
}
