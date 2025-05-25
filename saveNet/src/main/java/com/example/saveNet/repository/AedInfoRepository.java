package com.example.saveNet.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.saveNet.entity.AedInfo;

public interface AedInfoRepository extends JpaRepository<AedInfo, Long>{
    boolean existsByOrgNameAndBuildPlace(String orgName, String buildPlace);

    @Query("SELECT a FROM AedInfo a WHERE a.latitude BETWEEN :south AND :north AND a.longitude BETWEEN :west AND :east")
    List<AedInfo> findByBounds(
        @Param("south") double south,
        @Param("west") double west,
        @Param("north") double north,
        @Param("east") double east
    );

}
