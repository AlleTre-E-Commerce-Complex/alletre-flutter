class AuthErrorHandler {
  static Map<String, dynamic> handleSignUpError(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Handle specific API error responses
      if (response['error'] == 'Method Not Allowed') {
        return {
          'success': false,
          'message': 'This email is already registered. Please try logging in instead.'
        };
      }
      
      if (response['message'] is Map) {
        // Handle multilingual error messages
        return {
          'success': false,
          'message': response['message']['en'] ?? 'Registration failed. Please try again.'
        };
      }

      if (response['message'] is List) {
        // Handle validation errors
        return {
          'success': false,
          'message': (response['message'] as List).join(', ')
        };
      }

      // Handle other structured error messages
      if (response['message'] != null) {
        return {
          'success': false,
          'message': response['message'].toString()
        };
      }
    }

    // Default error message
    return {
      'success': false,
      'message': 'Unable to complete registration. Please check your connection and try again.'
    };
  }

  static Map<String, dynamic> handleSignInError(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Handle specific status codes
      if (response['statusCode'] == 405) {
        return {
          'success': false,
          'message': 'Please verify your email address before logging in. Check your inbox for a verification link.',
          'requiresVerification': true
        };
      }

      if (response['error'] == 'Invalid credentials') {
        return {
          'success': false,
          'message': 'Incorrect email or password. Please try again.'
        };
      }

      if (response['message'] is Map) {
        // Handle multilingual error messages
        String errorMessage = response['message']['en'] ?? 'Login failed';
        
        // Check for specific error conditions
        if (errorMessage.toLowerCase().contains('verify')) {
          return {
            'success': false,
            'message': 'Please verify your email address before logging in.',
            'requiresVerification': true
          };
        }
        
        return {
          'success': false,
          'message': errorMessage
        };
      }
    }

    // Default error message
    return {
      'success': false,
      'message': 'Unable to log in. Please check your connection and try again.'
    };
  }
}