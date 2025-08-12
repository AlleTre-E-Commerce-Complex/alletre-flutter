import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  static Future<Map<String, dynamic>> buyNowAuction({
    required int auctionId,
    required double amount,
    required String token,
    required String currency,
    CardFieldInputDetails? cardDetails,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/$auctionId/buy-now'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
        }),
      );

      debugPrint(
          'buyNowAuction response status: [32m${response.statusCode}[0m');
      debugPrint('buyNowAuction response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'];
        if (errorMessage is Map) {
          throw Exception(
              errorMessage['en'] ?? errorMessage['ar'] ?? 'Buy Now failed');
        }
        throw Exception(errorMessage ?? 'Buy Now failed');
      }

      final data = jsonDecode(response.body);
      // If Stripe confirmation is needed, handle here (optional)
      return data['data'] ?? data;
    } catch (e) {
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  static Future<Map<String, dynamic>> buyNowAuctionThroughWallet({
    required int auctionId,
    required double amount,
    required String token,
    required String currency,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/$auctionId/buy-now-through-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
        }),
      );

      debugPrint(
          'buyNowAuctionThroughWallet response status: [32m${response.statusCode}[0m');
      debugPrint('buyNowAuctionThroughWallet response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'];
        if (errorMessage is Map) {
          throw Exception(errorMessage['en'] ??
              errorMessage['ar'] ??
              'Buy Now (wallet) failed');
        }
        throw Exception(errorMessage ?? 'Buy Now (wallet) failed');
      }

      final data = jsonDecode(response.body);
      return data['data'] ?? data;
    } catch (e) {
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  static final ValueNotifier<bool> isLoadingPayment =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> paymentError =
      ValueNotifier<String?>(null);

  // Base URL for API endpoints
  static const String baseUrl = 'http://10.213.255.182:3001/api';

  // Seller deposit payment methods
  static Future<Map<String, dynamic>> payForAuction({
    required int auctionId,
    required String paymentType,
    required double amount,
    required String currency,
    required String token,
    CardFieldInputDetails? cardDetails,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      // Step 1: Create payment intent on server
      debugPrint('⭐️⭐️Creating payment intent with data: ${jsonEncode({
            'auctionId': auctionId,
            'amount': amount,
            'paymentType': paymentType,
            'currency': currency,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
          'paymentType': paymentType,
          'currency': currency,
        }),
      );

      debugPrint('⭐️⭐️Server response status: ${response.statusCode}');
      debugPrint('⭐️⭐️Server response body: ${response.body}');

      // Accept both 200 and 201 as success codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'];
        if (errorMessage is Map) {
          throw Exception(
              errorMessage['en'] ?? errorMessage['ar'] ?? '⭐️⭐️Payment failed');
        }
        throw Exception(errorMessage ?? '⭐️⭐️Payment failed');
      }

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['message'] ?? '⭐️⭐️Payment failed');
      }

      final clientSecret = data['data']['clientSecret'];
      debugPrint('⭐️⭐️Got client secret from server: $clientSecret');

      // Step 2: If using card payment, confirm with Stripe
      if (paymentType == 'card' &&
          cardDetails != null &&
          cardDetails.complete) {
        try {
          debugPrint('🌏🌏Confirming payment with Stripe...');
          // Confirm the payment with the card
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: BillingDetails(
                  email: data['data']['email'],
                ),
              ),
            ),
          );
          debugPrint('🌈🌈Stripe payment confirmed successfully');
        } on StripeException catch (e) {
          debugPrint('💥💥Stripe error: ${e.error.message}');
          throw Exception(e.error.message);
        }
      }

      return data['data'];
    } catch (e) {
      debugPrint('✨Payment error: $e');
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  static Future<Map<String, dynamic>> walletPayForAuction({
    required int auctionId,
    required double amount,
    required String token,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/walletPay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Wallet payment failed');
      }
    } catch (e) {
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  // Bidder deposit payment methods
  static Future<Map<String, dynamic>> payDepositByBidder({
    required int auctionId,
    required double amount,
    required double bidAmount,
    required String currency,
    required String token,
    CardFieldInputDetails? cardDetails,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      // Step 1: Create payment intent on server
      debugPrint('Creating payment intent with data: ${jsonEncode({
            'auctionId': auctionId,
            'amount': amount,
            'bidAmount': bidAmount,
            'currency': currency,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/$auctionId/bidder-deposit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
          'bidAmount': bidAmount,
          'currency': currency,
        }),
      );

      debugPrint('Server response status: ${response.statusCode}');
      debugPrint('Server response body: ${response.body}');

      // Accept both 200 and 201 as success codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'];
        if (errorMessage is Map) {
          throw Exception(errorMessage['en'] ??
              errorMessage['ar'] ??
              'Bidder deposit payment failed');
        }
        throw Exception(errorMessage ?? 'Bidder deposit payment failed');
      }

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Bidder deposit payment failed');
      }

      final clientSecret = data['data']['clientSecret'];
      debugPrint('Got client secret from server: $clientSecret');

      // Step 2: If using card payment, confirm with Stripe
      if (cardDetails != null && cardDetails.complete) {
        try {
          debugPrint('Confirming payment with Stripe...');
          // Confirm the payment with the card
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: BillingDetails(
                  email: data['data']['email'],
                ),
              ),
            ),
          );
          debugPrint('Stripe payment confirmed successfully');
        } on StripeException catch (e) {
          debugPrint('Stripe error: ${e.error.message}');
          throw Exception(e.error.message);
        }
      }

      return data['data'];
    } catch (e) {
      debugPrint('Payment error: $e');
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  static Future<Map<String, dynamic>> walletPayDepositByBidder({
    required int auctionId,
    required double amount,
    required double bidAmount,
    required String token,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/bidder/wallet-deposit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
          'bidAmount': bidAmount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Wallet bidder deposit failed');
      }
    } catch (e) {
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  // Auction purchase payment methods
  static Future<Map<String, dynamic>> payAuctionByBidder({
    required int auctionId,
    required double amount,
    required String currency,
    required String token,
    CardFieldInputDetails? cardDetails,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      // Step 1: Create payment intent on server
      debugPrint('Creating payment intent with data: ${jsonEncode({
            'auctionId': auctionId,
            'amount': amount,
            'currency': currency,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/$auctionId/bidder-purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
          'currency': currency,
        }),
      );

      debugPrint('Server response status: ${response.statusCode}');
      debugPrint('Server response body: ${response.body}');

      // Accept both 200 and 201 as success codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'];
        if (errorMessage is Map) {
          throw Exception(errorMessage['en'] ??
              errorMessage['ar'] ??
              'Auction purchase payment failed');
        }
        throw Exception(errorMessage ?? 'Auction purchase payment failed');
      }

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Auction purchase payment failed');
      }

      final clientSecret = data['data']['clientSecret'];
      debugPrint('Got client secret from server: $clientSecret');

      // Step 2: If using card payment, confirm with Stripe
      if (cardDetails != null && cardDetails.complete) {
        try {
          debugPrint('Confirming payment with Stripe...');
          // Confirm the payment with the card
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: BillingDetails(
                  email: data['data']['email'],
                ),
              ),
            ),
          );
          debugPrint('Stripe payment confirmed successfully');
        } on StripeException catch (e) {
          debugPrint('Stripe error: ${e.error.message}');
          throw Exception(e.error.message);
        }
      }

      return data['data'];
    } catch (e) {
      debugPrint('Payment error: $e');
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }

  static Future<Map<String, dynamic>> walletPayAuctionByBidder({
    required int auctionId,
    required double amount,
    required String token,
  }) async {
    isLoadingPayment.value = true;
    paymentError.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/$auctionId/wallet-bidder-purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'auctionId': auctionId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Wallet auction purchase failed');
      }
    } catch (e) {
      paymentError.value = e.toString();
      rethrow;
    } finally {
      isLoadingPayment.value = false;
    }
  }
}
