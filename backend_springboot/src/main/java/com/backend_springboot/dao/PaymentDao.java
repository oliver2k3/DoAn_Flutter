package com.backend_springboot.dao;


import com.backend_springboot.model.PaymentEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface PaymentDao extends CrudRepository<PaymentEntity, Integer> {
    List<PaymentEntity> findAll();
}
