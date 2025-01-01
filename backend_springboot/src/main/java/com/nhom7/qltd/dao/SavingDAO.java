package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.SavingEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface SavingDAO extends CrudRepository<SavingEntity, Integer>{

    List<SavingEntity> findByEmail(String email);
}
