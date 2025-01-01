package com.backend_springboot.service;


import com.backend_springboot.dao.BillDao;
import com.backend_springboot.model.BillEntity;
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
