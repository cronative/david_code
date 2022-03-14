//
//  ApiConstants.h
//  ViralVet
//
//  Created by Andrey Golovin on 27.10.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//
//#define GOOGLE_STORAGE @"http://storage.googleapis.com/vrdev/"
#define GOOGLE_STORAGE @"http://vrdev.storage.googleapis.com/"
#define APP_DOMAIN @"http://www.vocalreferences.com/vrapp/api/"
#define YOUTUBE @"http://www.vocalreferences.com/api/"
//#define APP_DOMAIN @"http://test.vocalreferences.com/vrapp/api/"
//#define YOUTUBE @"http://test.vocalreferences.com/api/"
#define LOGIN @"user/"
#define LOGIN_SOCIAL @"user/authBySocial/"
#define SIGN_UP @"user/signup/"
#define RESET_PASSWORD @"user/resetpassword/"
#define GET_INTRO @"content/getIntroVideo"
#define UPDATE_PROFILE @"user/profileupdate?auth_token="
#define GET_PROFILE @"user/getprofile?auth_token="
#define GET_ALL_VSS @"vss/getVSS?auth_token="
#define GET_USER_VSS @"vss/getVSSUser?auth_token="
#define SET_VSS @"vss/addVSSUser?auth_token="
#define EDIT_VSS @"vss/editVSSUser?auth_token="
//#define GET_CLOUD_LINK @"http://test.vr-cloud-1.appspot.com/getLink.php"
#define GET_CLOUD_LINK @"http://prod.vr-cloud-1.appspot.com/getLink.php"
#define ADD_RECORD @"content/addAndroid?auth_token="
#define EDIT_RECORD @"content/editAndroid?auth_token="
#define GET_ALLRECORDS @"content/mine?page_number=1&page_size=10000&auth_token="
#define DELETE_RECORD @"content/deleteAndroid?auth_token="
#define SET_FAVORITE @"content/setFavorite?auth_token="
#define CHANGE_PASS @"user/changePassword?auth_token="
#define CHANGE_USER_VIDEO @"user/changeProfileVideo?auth_token="
#define UPGRADE @"user/upgrade?auth_token="
#define VERIFY_RECEIPT @"user/verifySignature?deviceType=ios"
#define GET_VIEWS_COUNT @"content/getCountReviews?auth_token="