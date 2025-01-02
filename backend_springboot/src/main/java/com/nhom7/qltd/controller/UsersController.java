package com.nhom7.qltd.controller;

import com.nhom7.qltd.dto.*;
import com.nhom7.qltd.model.CardEntity;
import com.nhom7.qltd.model.SavingEntity;
import com.nhom7.qltd.model.UserEntity;
import com.nhom7.qltd.mapper.UserMapper;
import com.nhom7.qltd.service.CardService;
import com.nhom7.qltd.service.TransitionService;
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
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/user")
public class UsersController {
    private final UsersService userService;
    private final TransitionService transitionService;
    private final UserMapper userMapper;
    private final CardService cardService;

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

    @GetMapping("/{card}")
    public ResponseEntity<Object> getUserByCard(@PathVariable String card) {
        UserEntity userEntity = userService.getUserByCard(card);
        if (userEntity == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(userMapper.entityToDto(userEntity));
    }

    @PostMapping("/transfer")
    public ResponseEntity<Object> transfer(@RequestBody TransitionDto transitionDto, @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String currentCardNumber = userService.getCardNumberfromToken(token.substring(7));
            transitionDto.setSender(currentCardNumber);
            transitionService.performTransfer(transitionDto);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        } catch (DuplicateKeyException de) {
            responseBody.put("error", de.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(responseBody);
        }
    }

    @GetMapping("/all")
    public String getAllUsers() {
        return "List of users";
    }

    @PostMapping("/login")
    public ResponseEntity<Object> loginUser(@RequestBody LoginDto loginDto) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            UserEntity userEntity = userService.validateUser(loginDto);
            if (userEntity != null) {
                String token = userService.generateToken(userEntity);
                Boolean isVerified = userEntity.getIsVerified();
                System.out.println("Login successful for user: " + loginDto.getEmail());
                responseBody.put("is_verified", isVerified);
                responseBody.put("token", token);
                return ResponseEntity.ok(responseBody);
            } else {
                responseBody.put("error", "Invalid credentials");
                System.out.println("Invalid credentials for user: " + loginDto.getEmail());
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(responseBody);
            }
        } catch (Exception e) {
            responseBody.put("error", e.getMessage());
            System.out.println("Exception during login: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
        }
    }

    @GetMapping("/current-user")
    public ResponseEntity<Object> getCurrentUser(@RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            UserEntity userEntity = userService.getUserByEmail(userService.getEmailfromToken(token.substring(7)));
            System.out.println(userEntity);
            GetUserInfoDto getUserInfoDto = userMapper.entityToDto(userEntity);
            getUserInfoDto.setOtp(userEntity.getOtp());
            return ResponseEntity.ok(getUserInfoDto);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        } catch (EmptyResultDataAccessException ee) {
            responseBody.put("error", ee.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(responseBody);
        }
    }

    @PostMapping("/recipient-name")
    public ResponseEntity<Object> getRecipientNameByCardNumber(@RequestBody Map<String, String> request) {
        String cardNumber = request.get("cardNumber");
        UserEntity userEntity = userService.getUserByCard(cardNumber);

        if (userEntity == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(userEntity.getName());
    }

    @GetMapping("/receiver-name/{card}")
    public ResponseEntity<Object> getReceiverByCardNumber(@PathVariable String card) {
        UserEntity userEntity = userService.getUserByCard(card);

        if (userEntity == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(userEntity.getName());
    }

    @PostMapping("/add-card")
    public ResponseEntity<Object> addCardToUser(@RequestBody AddCardDto addCardDTO, @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String email = userService.getEmailfromToken(token.substring(7));
            UserEntity user = userService.getUserByEmail(email);

            String result = cardService.addCardToUser(addCardDTO, user);
            if (result.equals("Success")) {
                responseBody.put("message", "Card added successfully");
                return ResponseEntity.ok(responseBody);
            } else if (result.equals("User already has a card with the same card number and bank name")) {
                responseBody.put("error", "User already has a card with the same card number and bank name");

            } else if (result.equals("Card does not match existing records")) {
                responseBody.put("error", "Card does not match existing records");
            }
            return ResponseEntity.status(HttpStatus.CONFLICT).body(responseBody);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }

    @GetMapping("/my-cards")
    public ResponseEntity<Object> getCardsOfUser(@RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String email = userService.getEmailfromToken(token.substring(7));
            UserEntity user = userService.getUserByEmail(email);
            List<CardEntity> cardEntities = cardService.getCardsOfUser(user);
            List<CardInfoDto> cardInfoDtos = cardEntities.stream()
                    .map(cardInfo -> new CardInfoDto(
                            cardInfo.getCardNumber(),
                            cardInfo.getBankName(),
                            cardInfo.getExpiredDate(),
                            cardInfo.getName(),
                            cardInfo.getBalance()))

                    .toList();
            return ResponseEntity.ok(cardInfoDtos);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }

    @PostMapping("/deposit")
    public ResponseEntity<Object> depositToAccount(@RequestBody DepositDto depositDto, @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String email = userService.getEmailfromToken(token.substring(7));
            UserEntity user = userService.getUserByEmail(email);

            String result = cardService.depositToAccount(depositDto, user);
            if (result.equals("Deposit successful")) {
                responseBody.put("message", result);
                return ResponseEntity.ok(responseBody);
            } else {
                responseBody.put("error", result);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(responseBody);
            }
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }
    @PostMapping("/save-otp")
    public ResponseEntity<Object> saveOtp(@RequestBody Map<String, String> request, @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String email = userService.getEmailfromToken(token.substring(7));
            UserEntity user = userService.getUserByEmail(email);
            String otp = request.get("otp");
            userService.saveOtp(user, otp);
            responseBody.put("message", "OTP saved successfully");
            return ResponseEntity.ok(responseBody);
        } catch (Exception e) {
            responseBody.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
        }
    }
    @PostMapping("/verify-otp")
    public ResponseEntity<Object> verifyOtp(@RequestBody Map<String, String> request, @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String email = userService.getEmailfromToken(token.substring(7));
            UserEntity user = userService.getUserByEmail(email);
            String otp = request.get("otp");
            boolean isVerified = userService.verifyOtp(user, otp);
            if (isVerified) {
                responseBody.put("message", "OTP verified successfully");
                return ResponseEntity.ok(responseBody);
            } else {
                responseBody.put("error", "Invalid OTP");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responseBody);
            }
        } catch (Exception e) {
            responseBody.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
        }
    }
}