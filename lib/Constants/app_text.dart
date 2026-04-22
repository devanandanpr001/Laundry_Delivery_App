
class AppText {
  static const String AppName = 'Juggle Laundry';
  //Signup
  static const String Wlcm = 'Welcome';
  static const String SignupMsg = 'Sign Up to continue your delivery journey';
  static const String Button = 'SignUp';
  static const String HaveAccnt = 'Already have an account ';
  static const String SignupNameLabel = 'Name';
  static const String SignupNameHint = 'Your Name';
  static const String TermsAndConditions = 'I agree with the Terms & Conditions';
  static const String SignupSuccess = 'Signup Successful! Please Login.';
  static const String SignupError = 'Please fix the errors above';
  static const String LoginLink = ' LogIn!';

  //Login
  static const String WlcmBack = 'Welcome Back';
  static const String Frgt = 'Forgot Password';
  static const String FrgtPhoneLabel = 'Enter Phone No:';
  static const String FrgtBackSignIn = 'Back to sign in';
  static const String FrgtGetOtp = 'Get OTP';
  static const String FrgtValidPhone = 'Please enter a valid phone number';
  static const String FrgtNoAcc = "Don't have an account?";
  static const String FrgtSignUp = 'SignUp!';
  static const String Buttn = 'Login';
  static const String LoginNameLabel = 'Name';
  static const String LoginNameHint = 'name';
  static const String LoginMobileLabel = 'Mobile Number';
  static const String LoginMobileHint = '0000000000';
  static const String LoginPasswordLabel = 'Password';
  static const String RememberMe = 'Remember Me';
  static const String LoginSuccess = 'Login Successful! Redirecting...';
  static const String LoginErrorFillFields = 'Please fill in all fields correctly';

  //Homepage
  static const String Hello = 'Hello, ';
  static const String Assigned = 'Assigned orders';
  static const String Compltd = 'Completed orders';
  static const String OrdrAssigned = 'Order Assigned';
  static const String Online = 'Online';
  static const String Offline = 'Offline';

  // Navigation
  static const String NavHome = 'Home';
  static const String NavOrders = 'Orders';
  static const String NavProfile = 'Profile';

  //OrderPage
  static const String VrfTitle = 'Verification';
  static const String VrfSubtitle = 'Enter the 4 digit code sent to your number';
  static const String InvalidOtp = 'Invalid OTP';
  static const String WaitText = 'Wait for 00:';
  static const String ResendOtp = 'Resend OTP';
  static const String OtpSentSuccess = 'OTP Sent Successfully!';

  static const String CannotAccpt = "Cannot Accept!\nYou already have an assigned order";
  static const String FinishOrderMsg = 'Finish your active order first!';
  static const String UrOffline = 'You are offline';
  static const String All = 'All';
  static const String Asignd = 'Assigned';
  static const String Cmpltd = 'Completed';
  static const String NoAssgnd = 'No Orders Assigned';
  static const String NoCmpltd = 'No Orders Completed';
  static const String NoOrdersAvailable = 'No orders available';
  static const String ActiveOrders = 'Active Orders';
  static const String PickUpOrders = 'Pick Up';
  static const String DeliveryOrders = 'Delivery';
  static const String ActiveTasks = 'Active Tasks';
  static const String CompletedOrders = 'Completed Orders';
  static const String Delivered = 'Delivered';
  static const String NewOrders = 'New Orders';
  static const String OrderSingle = 'Order';
  static const String OrderPlural = 'Orders';
  static const String ReviewedConfirmed = ' • Reviewed & confirmed';

  //pickup
  static const String titlePickup = 'Pick up location';
  static const String subtitlePickUp = "1 Order • Reviewed & confirmed";
  static const String ArrivedMsg = 'Arrived for pick up';
  static const String Call = 'Call';

  //DeliveryLocation
  static const String titleDelivery = 'Delivery location';
  static const String ArrivedMsgD = 'Arrived for Delivery';
  static const String DeliveryTimeValue = '33 Min';
  static const String DeliveryDistValue = '19km';
  static const String CustNameValue = 'Praveena';
  static const String CustPhoneValue = '+916321548562';

  //Bundle Dialog
  static const String BundleLabel = 'Bundle';
  static const String PerWeightLabel = 'Per weight';
  static const String ServicesLabel = 'Services:';
  static const String SelectServicesHint = 'Select Services';
  static const String WeightLabel = 'Weight:';
  static const String PerKgHint = 'Per /Kg';
  static const String TotalAmountLabel = 'Total amount: ';
  static const String AddBtn = 'Add';
  static const List<String> DefaultServices = [
    "Wash & fold",
    "Wash and ironing",
    "Premium ironing",
    "Steam press",
    "Starching"
  ];

  //profile
  static const String TitleP = 'Profile';
  static const String Orders = 'Orders';
  static const String MyOdrBtn = 'My Orders';
  static const String MyAcnt = 'My Account';
  static const String ChangePfleBtn = 'Change profile image';
  static const String ChangePswd = 'Change password';
  static const String Notfcn = 'Notifications';
  static const String NotifTitle = 'Notification';
  static const String NotifCountSuffix = ' notification';
  static const String NotifConfirm = 'Confirm?';
  static const String NotifDelete = 'Delete';
  static const String NotifSelectAll = 'Select all';
  static const String NoNotifications = 'No Notifications';
  static const String Support = 'Support';
  static const String SupportBtn = 'Help & Support';
  static const String Privacy = 'Privacy policy';
  static const String LogOut = 'Logout';

  //MyOrders
  static const String TitleMy = 'My Orders';
  static const String OrderId = 'Oder Id: ';

  //changePassword
  static const String titlePass = 'Change Password';
  static const String NewPasswordTitle = 'New Password';
  static const String NewPasswordHint = '8 symbols at least';
  static const String PasswordHint = '********';
  static const String NewPasswordEnter = 'Enter New Password';
  static const String NewPasswordConfirm = 'Confirm Password';
  static const String NewPasswordErrorEmpty = 'Fields cannot be empty';
  static const String NewPasswordErrorMatch = 'Passwords do not match';
  static const String NewPasswordErrorLength = 'Password must be at least 8 characters';
  static const String NewPasswordSuccess = 'Password reset successfully';
  static const String SubmitButton = 'Submit';
  static const String MsgPass = 'Your password must be at least 6 characters\nand should a combination of numbers, letters\n          and special characters (!\$@%).';
  static const String SuccessPass = 'Password changed successfully';
  static const String BtnPass = 'Changes Password';

  //ChangeProfile
  static const String TitleProfile = 'Change profile image';
  static const String BtnProfile = 'Change';

  // Gallery
  static const String GalleryTitle = 'Gallery';
  static const String SelectedSuffix = ' Selected';

  // Order Card Elements & Common Labels
  static const String PickupAssignedToYou = 'Pick up assigned to you';
  static const String OrderDeliveredTitle = 'Order Delivered';
  static const String OutForDelivery = 'Out for delivery';
  static const String DummyTime = '2:15 am';
  static const String ItemsLabel = 'Items';
  static const String StepPickupAssigned = 'Pickup Assigned';
  static const String StepPickedUp = 'Picked up';
  static const String SelectedImages = 'Selected Images';
  static const String UploadedImages = 'Uploaded images';
  static const String SeeMore = 'See More';
  static const String BtnStartPickup = 'Start to Pick up';
  static const String BtnUpload = 'Upload from gallery';
  static const String BtnOrderPicked = 'Order Picked';
  static const String BtnStartDeliver = 'Start to Deliver';
  static const String BtnView = 'view';
  static const String BtnAccept = 'Accept';
  static const String PickupAddress = 'Pickup Address';
  static const String CashOnDelivery = 'Cash On Delivery';
  static const String AmountPaid = 'amount paid';
  static const String NotYetPaid = 'Not yet paid';
  static const String OrderPickedTitle = 'Order Picked';
  static const String CurrentPasswordHint = 'current password';
  static const String NewPasswordInputHint = 'new password';
  static const String RetypeNewPasswordHint = 're-type new password';

  // Help & Support Screen
  static const String HelpAndSupportTitle = 'Help and support';
  static const String HelpAndSupportSubtitle = 'Need help? We’re here to support you.';
  static const String DeliveryIssuesTitle = '🚚 Delivery Issues.';
  static const String DeliveryIssuesDescription = 'For pickup/delivery problems, route confusion, or customer complaints:';
  static const String DeliveryIssuesContact = 'Contact Operations: +91632158426';
  static const String SalaryIncentivesTitle = '💰 Salary & Incentives';
  static const String AppTechnicalIssuesTitle = '📱 App / Technical Issues';
  static const String EmergencyTitle = '🚨 Emergency';
  static const String EmergencyDescription = 'In case of accident or safety concern:';
  static const String EmergencyContact = '📞 Emergency Contact: +917265124462';
  static const String ReportIssuesTitle = '⚠️ Report Issues';
  static const String ReportIssuesInstruction1 = 'If you face:';
  static const String ReportIssuesBullet1 = '•Customer misconduct.';
  static const String ReportIssuesBullet2 = '•Safety problems.';
  static const String ReportIssuesBullet3 = '•Payment disputes.';
  static const String ReportIssuesInstruction2 = '•Report immediately to Operations Team.';
  static const String ManagementCommitment = 'SLAMS WASH Management is committed to \n               supporting all delivery staff.';

  // MyOrders dummy/extra
  static const String Today = 'Today';
  static const String Pathalam = 'Pathalam';
}