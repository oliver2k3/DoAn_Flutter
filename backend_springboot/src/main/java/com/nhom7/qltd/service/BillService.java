package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.BillDao;
import com.nhom7.qltd.model.BillEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BillService {
    private final BillDao billDao;
    private final UsersService userService;
    private final PaymentService paymentService;

    public BillEntity getBill(String code, String category) {
        return billDao.findByCodeAndCategory(code, category).orElseThrow(() -> new EmptyResultDataAccessException("Bill not found", 1));
    }

    public void payBill(String code, String token) {

        BillEntity billEntity = billDao.findByCode(code).orElseThrow(() -> new EmptyResultDataAccessException("Bill not found", 1));
        userService.payBill(billEntity.getAmount() -( billEntity.getFee() + billEntity.getTax()), token);
        paymentService.payBill(billEntity, token);
        billDao.delete(billEntity);
    }

}
