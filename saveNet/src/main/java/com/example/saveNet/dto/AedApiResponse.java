package com.example.saveNet.dto;

import java.util.List;

import lombok.Data;

/// 사용하고자 하는 JSON의 구조는 response → body → items → item
@Data
public class AedApiResponse {
    private Response response;

    @Data
    public static class Response {
        private Body Body;
    }


    @Data
    public static class Body {
        private Items items;
        private int totalCount;
        private int pageNo;
        private int numOfRows;
    }

    @Data
    public static class Items {
        private List<AedInfoDto> item;
    }
}
