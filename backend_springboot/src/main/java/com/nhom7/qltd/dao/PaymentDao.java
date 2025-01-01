package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.PaymentEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface PaymentDao extends CrudRepository<PaymentEntity, Integer> {
    List<PaymentEntity> findAll();
}
