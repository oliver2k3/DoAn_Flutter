package com.backend_springboot.dao;

import com.backend_springboot.model.StatusEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface StatusDao extends CrudRepository<StatusEntity, Integer> {
    List<StatusEntity> findAll();

}
