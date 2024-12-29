package com.backend_springboot.dao;


import com.backend_springboot.model.SavingEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface SavingDao extends CrudRepository<SavingEntity, Integer>{

    List<SavingEntity> findByEmail(String email);
}
