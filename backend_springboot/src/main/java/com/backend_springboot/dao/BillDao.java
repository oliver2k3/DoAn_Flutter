package com.backend_springboot.dao;


import com.backend_springboot.model.BillEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface BillDao extends CrudRepository<BillEntity, String> {
    List<BillEntity> findAll();

    Optional<BillEntity> findByCode(String code);

    Optional<BillEntity> findByCodeAndCategory(String code, String category);
}
