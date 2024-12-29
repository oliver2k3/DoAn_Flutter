package com.backend_springboot.dao;


import com.backend_springboot.model.TransitionEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface TransitionDao extends CrudRepository<TransitionEntity, Integer> {
    List<TransitionEntity> findByFromUser(String fromUser);
}
