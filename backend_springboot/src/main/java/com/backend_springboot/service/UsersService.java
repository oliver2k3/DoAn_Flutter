package com.backend_springboot.service;

import com.backend_springboot.dao.UserDao;
import com.backend_springboot.dto.RegisterDto;
import com.backend_springboot.model.UserEntity;
import com.backend_springboot.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UsersService {
    private final UserDao userDao;
    private final JwtUtil jwtUtil;

    public UserEntity createUser(RegisterDto registerDto) {

        String error = inputCheck(registerDto);

        // check if there is any error
        if (!error.isEmpty()) {
            throw new IllegalArgumentException(error);
        }

        if (userDao.findByEmail(registerDto.getEmail()).isPresent()) {
            throw new DuplicateKeyException("Email already exists");
        }

        UserEntity userEntity = new UserEntity();
        userEntity.setName(registerDto.getName());
        userEntity.setEmail(registerDto.getEmail());
        userEntity.setPassword(registerDto.getPassword());
        userEntity.setCreated(LocalDateTime.now());
        userEntity.setUpdated(LocalDateTime.now());
        return userDao.save(userEntity);
    }

    public UserEntity getUserByCard(String card) {
        return userDao.findByCardNumber(card).orElse(null);
    }
    public UserEntity getUserByEmail(String email) {
        return userDao.findByEmail(email).orElse(null);
    }

    public String getEmailfromToken(String token) {
        return jwtUtil.getEmailFromJwt(token);
    }

    public String getCardNumberfromToken(String token) {
        String email = jwtUtil.getEmailFromJwt(token);
        UserEntity userEntity = userDao.findByEmail(email).orElse(null);
        return userEntity.getCardNumber();
    }
    public Integer getUserIdfromToken(String token) {
        String email = jwtUtil.getEmailFromJwt(token);
        UserEntity userEntity = userDao.findByEmail(email).orElse(null);
        return userEntity.getId();
    }
    public void payBill(Double amount, String token) {
        String email = jwtUtil.getEmailFromJwt(token);
        UserEntity userEntity = userDao.findByEmail(email).orElse(null);
        if (userEntity.getBalance() < amount) {
            throw new IllegalArgumentException("Insufficient balance");
        }
        userEntity.setBalance(userEntity.getBalance() - amount);
        userDao.save(userEntity);
    }

    private String inputCheck(RegisterDto registerDto) {
        StringBuilder error = new StringBuilder();
        if (registerDto.getName() == null || registerDto.getName().isEmpty()) {
            error.append("Name is required");
        } else if (registerDto.getPassword() == null || registerDto.getPassword().isEmpty()) {
            error.append("Password is required");
        } else if (registerDto.getEmail() == null || registerDto.getEmail().isEmpty()) {
            error.append("Email is required");
        }
        return error.toString();
    }
    public UserEntity getUserById(Integer userId) {
        return userDao.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    public void updateUser(UserEntity user) {
        userDao.save(user);
    }
}
