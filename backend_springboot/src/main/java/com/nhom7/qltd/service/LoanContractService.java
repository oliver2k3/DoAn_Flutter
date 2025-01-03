package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.LoanContractDAO;
import com.nhom7.qltd.model.LoanContractEntity;
import com.nhom7.qltd.model.LoanEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LoanContractService {

    private final LoanContractDAO loanContractDAO;

    public List<LoanContractEntity> getAllContracts() {
        return (List<LoanContractEntity>) loanContractDAO.findAll();
    }
}
