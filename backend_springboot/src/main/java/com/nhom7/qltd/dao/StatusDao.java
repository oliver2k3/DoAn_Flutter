package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.StatusEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface StatusDao extends CrudRepository<StatusEntity, Integer> {
    List<StatusEntity> findAll();

    StatusEntity getStatusById(int i);
}
