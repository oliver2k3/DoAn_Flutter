package com.nhom7.qltd.dto;

import lombok.Data;

@Data
public class AddCardDto {
    private String name;
    private String bankName;
    private String cardNumber;
    private String expiredDate;
    private String ccv;
}