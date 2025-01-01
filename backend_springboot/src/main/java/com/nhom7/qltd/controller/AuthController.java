package com.nhom7.qltd.controller;

import com.nhom7.qltd.dto.LoginDto;
import com.nhom7.qltd.dto.LoginReponseBodyDto;
import com.nhom7.qltd.dto.RegisterDto;
import com.nhom7.qltd.model.EmailDetails;
import com.nhom7.qltd.model.UserEntity;
import com.nhom7.qltd.mapper.UserMapper;
import com.nhom7.qltd.service.AuthService;
import com.nhom7.qltd.service.EmailService;
import com.nhom7.qltd.service.UsersService;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final UserMapper userMapper;
    private final UsersService userService;
    private final EmailService emailService;

    @GetMapping("/forgot-pass/{email}")
    public ResponseEntity<Object> sendPassToMail(@PathVariable String email) {
        UserEntity userEntity = userService.getUserByEmail(email);
        Map<String, String> responseBody = new HashMap<>();


        if (userEntity == null) {
            responseBody.put("error", "User not found");

            return ResponseEntity.notFound().build();
        }

        EmailDetails emailDetails = EmailDetails.builder().recipient(email).msgBody("Your password is: " + userEntity.getPassword()).subject("Matcha Bank").build();

        emailService.sendSimpleMail(emailDetails);
        responseBody.put("status", "Successfull!!!");


        return ResponseEntity.ok(responseBody);
    }

    @PostMapping("/register")
    public ResponseEntity<Object> createUser(@RequestBody RegisterDto registerDto) {
        Map<String, Object> responseBody = new HashMap<>();
        try {

            UserEntity userEntity = authService.createUser(registerDto);

            URI location = ServletUriComponentsBuilder
                    .fromCurrentRequest()
                    .path("/{email}")
                    .buildAndExpand(registerDto.getEmail())
                    .toUri();

            return ResponseEntity.created(location).body(userEntity);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        } catch (DuplicateKeyException de) {
            responseBody.put("error", de.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(responseBody);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<Object> login(@RequestBody LoginDto loginDto) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            LoginReponseBodyDto token = authService.login(loginDto.getEmail(), loginDto.getPassword());
            return ResponseEntity.ok(token);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        } catch (EmptyResultDataAccessException ee) {
            responseBody.put("error", ee.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(responseBody);
        }
    }
}
