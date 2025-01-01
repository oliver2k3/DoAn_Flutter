package com.backend_springboot.controller;


import com.backend_springboot.dto.SearchPaymentDto;
import com.backend_springboot.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/payment")
public class PaymentController {
    private final PaymentService paymentService;

    @GetMapping("/search")
    public ResponseEntity<Object> searchPayment(@ModelAttribute SearchPaymentDto searchPaymentDto) {
        return ResponseEntity.ok(paymentService.searchPayment(searchPaymentDto));
    }

    @GetMapping("/current")
    public ResponseEntity<Object> searchMyPayment(@RequestParam(required = false) String category, @RequestHeader("Authorization") String token){
        return ResponseEntity.ok(paymentService.searchMyPayment(category, token.substring(7)));
    }
}
