package com.backend_springboot.controller;

import com.backend_springboot.dto.GetUserInfoDto;
import com.backend_springboot.dto.RegisterDto;
import com.backend_springboot.mapper.UserMapper;
import com.backend_springboot.model.UserEntity;
import com.backend_springboot.service.UsersService;
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
@RequestMapping("/api/user")
public class UsersController {
    private final UsersService userService;

    private final UserMapper userMapper;


    @PostMapping
    public ResponseEntity<Object> createUser(@RequestBody RegisterDto registerDto) {
        Map<String, Object> responseBody = new HashMap<>();
        try {

            UserEntity userEntity = userService.createUser(registerDto);

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
    @GetMapping("/current-user")
    public ResponseEntity<Object> getCurrentUser(@RequestHeader("Authorization") String token){
        Map<String, Object> responseBody = new HashMap<>();
        try {
            UserEntity userEntity = userService.getUserByEmail(userService.getEmailfromToken(token.substring(7)));
            System.out.println(userEntity);
            GetUserInfoDto getUserInfoDto = userMapper.entityToDto(userEntity);
            return ResponseEntity.ok(getUserInfoDto);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        } catch (EmptyResultDataAccessException ee) {
            responseBody.put("error", ee.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(responseBody);
        }
    }



}
