package com.nhom7.qltd.controller;

import com.nhom7.qltd.dao.LoanContractDAO;
import com.nhom7.qltd.dto.ListContractDto;
import com.nhom7.qltd.dto.LoanDto;
import com.nhom7.qltd.model.LoanContractEntity;
import com.nhom7.qltd.model.LoanEntity;
import com.nhom7.qltd.model.UserEntity;
import com.nhom7.qltd.service.LoanService;
import com.nhom7.qltd.service.LoanContractService;
import com.nhom7.qltd.service.UsersService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

import static java.util.stream.Collectors.toList;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/admin")
public class AdminController {
    private final LoanService loanService;
    private final UsersService userService;
    private final LoanContractService loanContractService;
    private final LoanContractDAO loanContractDAO;

    // Loan management
    @GetMapping("/all-loan-contracts")
    public ResponseEntity<Object> getAllLoans() {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            List<LoanContractEntity> loans = loanContractService.getAllContracts();
            List<ListContractDto> listContractDtos = loans.stream().
                    map(contract -> new ListContractDto(contract.getId(),
                            contract.getUser().getName(),
                            contract.getLoan().getName(),
                            contract.getInterestRate(),
                            contract.getLoanTerm(),
                            contract.getTotalPayment(),
                            contract.getTotalInterest(),
                            contract.getPaid(),
                            contract.getRemaining(),
                            contract.getLoanAmount(),
                            contract.getStatus().getName()))
                    .toList();
            return ResponseEntity.ok(listContractDtos);
        } catch (Exception e) {
            responseBody.put("error", e.getMessage());
            return ResponseEntity.status(500).body(responseBody);
        }
    }

    // Loan contract management
    @PostMapping("/loan-contract/approve")
    public ResponseEntity<Object> approveLoanContract(@RequestParam int loanContractId) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            loanService.approveLoan(loanContractId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }


    @PostMapping("/loan-contract/reject")
    public ResponseEntity<Object> rejectLoanContract(@RequestParam int contractId) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            loanService.rejectLoanContract(contractId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }

    }

}