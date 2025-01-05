package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.LoanContractDAO;
import com.nhom7.qltd.dao.LoanDao;
import com.nhom7.qltd.dao.StatusDao;
import com.nhom7.qltd.dto.LoanDto;

import com.nhom7.qltd.model.LoanContractEntity;
import com.nhom7.qltd.model.LoanEntity;
import com.nhom7.qltd.model.StatusEntity;
import com.nhom7.qltd.model.UserEntity;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LoanService {
    private final LoanContractDAO loanContractDAO;
    private final UsersService userService;
    private final StatusDao statusDao;
    private final LoanDao loanDao;

    public void createLoan(LoanDto loanDto) {
        UserEntity user = userService.getUserByEmail(loanDto.getEmail());
        Optional<LoanEntity> goiVay = loanDao.findById(loanDto.getLoanId());
        StatusEntity status = statusDao.getStatusById(1);

        LoanContractEntity loanContract = new LoanContractEntity();
        loanContract.setUser(user);
        goiVay.ifPresent(loanContract::setLoan);
        loanContract.setStatus(status);
        loanContract.setLoanAmount(loanDto.getLoanAmount());
        loanContract.setLoanTerm(loanDto.getLoanDuration());

        float interestRate;
        if (loanDto.getLoanDuration() == 6) {
            interestRate = goiVay.map(LoanEntity::getBaseInterestRate).orElse(0.0f);
        } else if (loanDto.getLoanDuration() == 12) {
            interestRate = goiVay.map(LoanEntity::getInterestRate2).orElse(0.0f);
        } else if (loanDto.getLoanDuration() == 24) {
            interestRate = goiVay.map(LoanEntity::getInterestRate3).orElse(0.0f);
        } else {
            throw new IllegalArgumentException("Invalid loan duration");
        }
        loanContract.setInterestRate(interestRate);

        loanContract.setCreatedDate(LocalDateTime.now());
        loanContract.setExpirationDate(LocalDateTime.now().plusMonths(loanDto.getLoanDuration()));
        float monthlyInterest = (interestRate / 100 / 12);
        float tongLai = loanContract.getLoanAmount() * monthlyInterest * loanContract.getLoanTerm();
        float tongTien = loanContract.getLoanAmount() + tongLai;
        float emi = tongTien / loanContract.getLoanTerm();
        loanContract.setTotalInterest(tongLai);
        loanContract.setTotalPayment(tongTien);
        loanContract.setEmi(emi);
        loanContract.setPaid(0);
        loanContract.setRemaining(tongTien);
        loanContractDAO.save(loanContract);
    }

    public List<LoanEntity> getAllLoans() {
        return (List<LoanEntity>) loanDao.findAll();
    }
    public void approveLoan(int loanContractId) {
        LoanContractEntity loanContract = loanContractDAO.findById(loanContractId)
                .orElseThrow(() -> new IllegalArgumentException("Loan contract not found"));

        if (loanContract.getStatus().getId() != 1) {
            throw new IllegalArgumentException("Loan contract is not in a pending state");
        }

        UserEntity user = loanContract.getUser();
        user.setBalance(user.getBalance() + loanContract.getLoanAmount());
        userService.updateUser(user);

        StatusEntity approvedStatus = statusDao.getStatusById(2); // Assuming 2 is the ID for "Approved" status
        loanContract.setStatus(approvedStatus);
        loanContract.setCreatedDate(LocalDateTime.now());
        loanContract.setThisMonthAmount(loanContract.getEmi());
        loanContract.setNextPayment(LocalDateTime.now().plusMonths(1));
        loanContract.setExpirationDate(LocalDateTime.now().plusMonths(loanContract.getLoanTerm()));
        loanContractDAO.save(loanContract);
    }
    public void rejectLoanContract(int contractId) {
        LoanContractEntity loanContract = loanContractDAO.findById(contractId)
                .orElseThrow(() -> new IllegalArgumentException("Loan contract not found"));
        if (loanContract.getStatus().getId() != 1) {
            throw new IllegalArgumentException("Loan contract is not in a pending state");
        }
        StatusEntity rejectedStatus = statusDao.getStatusById(3); // Assuming 3 is the ID for "Rejected" status
        loanContract.setStatus(rejectedStatus);
        loanContractDAO.save(loanContract);
    }

    public List<LoanContractEntity> getMyLoanContracts(String email) {
        UserEntity user = userService.getUserByEmail(email);
        List<LoanContractEntity> loanContracts = loanContractDAO.findByUser(user);

        for (LoanContractEntity loanContract : loanContracts) {
            if (loanContract.getNextPayment() != null && loanContract.getNextPayment().isBefore(LocalDateTime.now())) {
                StatusEntity overdueStatus = statusDao.getStatusById(4); // Assuming 4 is the ID for "Overdue" status
                loanContract.setStatus(overdueStatus);
                loanContractDAO.save(loanContract);
            }
        }
        return loanContracts;
    }

    public void makePayment(int contractId, String email) {
        UserEntity user = userService.getUserByEmail(email);
        LoanContractEntity loanContract = loanContractDAO.findById(contractId)
                .orElseThrow(() -> new IllegalArgumentException("Loan contract not found"));



        if (user.getBalance() < loanContract.getThisMonthAmount()) {
            throw new IllegalArgumentException("Insufficient balance");
        }

        user.setBalance(user.getBalance() - loanContract.getThisMonthAmount());
        loanContract.setPaid(loanContract.getPaid() + loanContract.getThisMonthAmount());
        loanContract.setRemaining(loanContract.getRemaining() - loanContract.getThisMonthAmount());
        loanContract.setNextPayment(loanContract.getNextPayment().plusMonths(1));
        loanContract.setThisMonthAmount(loanContract.getEmi());
        loanContract.setStatus(statusDao.getStatusById(2)); // Assuming 2 is the ID for "Approved" status
        loanContractDAO.save(loanContract);
        userService.updateUser(user);
    }
}