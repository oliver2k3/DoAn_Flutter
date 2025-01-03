package com.nhom7.qltd.dto;

import lombok.Data;

@Data
public class LoanDto {
    private String email;
    private float loanAmount;
    private int loanDuration;
    private int loanId;
}
