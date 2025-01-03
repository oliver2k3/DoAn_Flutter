package com.nhom7.qltd.controller;

import com.nhom7.qltd.dto.ListRequestsDto;
import com.nhom7.qltd.dto.RequestDepositDto;
import com.nhom7.qltd.model.DepositRequestEntity;
import com.nhom7.qltd.service.DepositRequestService;
import com.nhom7.qltd.service.TransitionService;
import com.nhom7.qltd.service.UsersService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/transition")
public class TransitionController {
    private final TransitionService transitionService;
    private final DepositRequestService depositRequestService;
    private final UsersService userService;
    @GetMapping("/current")
    public ResponseEntity<Object> searchMyPayment( @RequestHeader("Authorization") String token){
        return ResponseEntity.ok(transitionService.getMyTransition(token.substring(7)));
    }
    @GetMapping("/received")
    public ResponseEntity<Object> getReceivedTransitions(@RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(transitionService.getReceivedTransitions(token.substring(7)));
    }

    @PostMapping("/create-request")
    public ResponseEntity<Object> createDepositRequest(@RequestBody RequestDepositDto requestDepositDto,  @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
       String email = userService.getEmailfromToken(token.substring(7));
        requestDepositDto.setRequesterEmail(email);
        try {
            depositRequestService.createDepositRequest(requestDepositDto);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }

    @PostMapping("/approve")
    public ResponseEntity<Object> approveDepositRequest(@RequestParam int requestId) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            depositRequestService.approveDepositRequest(requestId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }
    @PostMapping("/reject")
    public ResponseEntity<Object> rejectDepositRequest(@RequestParam int requestId) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            depositRequestService.rejectDepositRequest(requestId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }
    @GetMapping("/my-requests")
    public ResponseEntity<Object> getMyDepositRequests(@RequestHeader("Authorization") String token) {
        String email = userService.getEmailfromToken(token.substring(7));
        Map<String, Object> responseBody = new HashMap<>();
        try {
            List<DepositRequestEntity> allRequests = depositRequestService.getAllRequests(email);
            List<ListRequestsDto> allRequestsDto = allRequests.stream()
                    .map(request -> new ListRequestsDto(
                            request.getId(),
                            request.getRequester().getName(),
                            request.getReceiver().getName(),
                            request.getStatus().getId(),
                            request.getAmount(),
                            request.getMessage(),
                            request.getCreatedDate(),
                            request.getApprovedDate(),
                            request.getStatus().getName(),
                            request.getRequester().getCardNumber(),
                            request.getReceiver().getCardNumber()
                            )).toList();
            return ResponseEntity.ok(allRequestsDto);
        } catch (Exception e) {
            responseBody.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
        }
    }
}
