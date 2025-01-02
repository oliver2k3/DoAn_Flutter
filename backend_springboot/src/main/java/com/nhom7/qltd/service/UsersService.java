package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.UserDao;
import com.nhom7.qltd.dto.LoginDto;
import com.nhom7.qltd.dto.RegisterDto;
import com.nhom7.qltd.model.UserEntity;
import com.nhom7.qltd.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

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
        userEntity.setBalance(0.0);
        userEntity.setCardNumber(registerDto.getPhoneNumber());
        userEntity.setBank("VPPAY");
        userEntity.setIsVerified(false);
        userEntity.setPhone(registerDto.getPhoneNumber());
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
    public UserEntity validateUser(LoginDto loginDto) {
        Optional<UserEntity> userEntity = userDao.findByEmail(loginDto.getEmail());
        if (userEntity.isPresent() && userEntity.get().getPassword().equals(loginDto.getPassword())) {
            return userEntity.get();
        }
        return null;
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
    public String generateToken(UserEntity userEntity) {
        return jwtUtil.generateToken(userEntity);
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
    public void saveOtp(UserEntity userEntity, String otp) {
        userEntity.setOtp(otp);
        userEntity.setIsVerified(true);
        userDao.save(userEntity);
    }
    public boolean verifyOtp(UserEntity user, String otp) {
        if (user != null && otp.equals(user.getOtp())) {

            return true;
        }
        return false;
    }
}