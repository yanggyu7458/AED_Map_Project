package com.example.saveNet.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.saveNet.entity.AedInfo;
import com.example.saveNet.entity.AedUpdateRequest;
import com.example.saveNet.repository.AedInfoRepository;
import com.example.saveNet.repository.AedUpdateRequestRepository;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;


@RestController
@RequestMapping("/api/aeds")
@CrossOrigin(origins = "*")
public class AedInfoController {
    
    private final AedInfoRepository aedInfoRepository;
    @Autowired
    private AedUpdateRequestRepository aedUpdateRequestRepository;

    @Autowired
    public AedInfoController(AedInfoRepository aedInfoRepository) {
        this.aedInfoRepository = aedInfoRepository;
    }

    // [GET] 전체 AED 리스트 조회
    public String getMethodName(@RequestParam String param) {
        return new String();
    }

    // @GetMapping(produces = "application/json; charset=UTF-8")
    // public List<AedInfo> getAllAeds() {
    //     return aedInfoRepository.findAll();
    // }

    @GetMapping(produces = "application/json; charset=UTF-8")
    public List<AedInfo> getAedsInBounds(
        @RequestParam("south") double south,
        @RequestParam("west") double west,
        @RequestParam("north") double north,
        @RequestParam("east") double east
    ) {
        return aedInfoRepository.findByBounds(south, west, north, east);
    }

    

    // [POST] 새로운 AED 정보 등록
    @PostMapping
    public AedInfo createAed(@RequestBody AedInfo aedInfo) {
        return aedInfoRepository.save(aedInfo);
    }

    // 기존 AED 정보 수정 요청
    @PostMapping(value = "/{id}/suggest", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> suggestAEDUpdate(@PathVariable Long id, @RequestPart(required = false) MultipartFile photo, @RequestParam Map<String, String> updates) {
        Optional<AedInfo> optional = aedInfoRepository.findById(id);
        if (optional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("AED 정보가 존재하지 않습니다.");
        }

        AedUpdateRequest request = new AedUpdateRequest();

        request.setOriginalAedId(id);
        request.setOrgName(updates.get("orgName"));
        request.setBuildAddress(updates.get("buildAddress"));
        request.setBuildPlace(updates.get("buildPlace"));
        request.setManager(updates.get("manager"));
        request.setManagerTel(updates.get("managerTel"));
        request.setModel(updates.get("model"));

        if (updates.containsKey("latitude"))
        request.setLatitude(Double.valueOf(updates.get("latitude")));
        if (updates.containsKey("longitude"))
        request.setLongitude(Double.valueOf(updates.get("longitude")));

        if (photo != null) {
            request.setPhotoFileName(photo.getOriginalFilename());
            System.out.println("사진 파일 이름 : " + photo.getOriginalFilename());
        }

        aedUpdateRequestRepository.save(request);

        return ResponseEntity.ok("제안 접수 완료");
    }
}
