Pin Definition for AskSin Analyzer running on OdroidGo   
   
See https://wiki.odroid.com/odroid_go/odroid_go#odroid-go_gpio_pin_mapping    
and https://wiki.odroid.com/odroid_go/odroid_go#odroid-go_header_p2_description
   
//Pin definitions for external switches
#define START_WIFIMANAGER_PIN    27   // Button Select LOW = on boot: start wifimanager, on run: switch between tft screens   
#define SHOW_DISPLAY_LINES_PIN   32   // Button A      LOW = show lines between rows   
#define SHOW_DISPLAY_DETAILS_PIN 33   // Button B      LOW = show detailed information on display, HIGH = show only main infos   
#define ONLINE_MODE_PIN          13   // Button Menu   LOW = enable WIFI   
#define RSSI_PEAK_HOLD_MODE_PIN  39   // Button Start  LOW = show peak line only for noisefloor, HIGH = show also for hm(ip) messages   
   
//Pin definition for LED
#define AP_MODE_LED_PIN          2    // Status LED   
   
//Pin definition for SD Card   
#define SD_CS                    22   
   
//Pin definitions for serial connection to AskSinSniffer   
#define EXTSERIALTX_PIN          15   
#define EXTSERIALRX_PIN          4   
#define EXTSERIALBAUDRATE        57600   
   
#ifdef USE_DISPLAY
#define TFT_LED                 14   
#define TFT_CS                   5   
//#define TFT_RST                 26  // No ESP Pin for TFT Reset connected   
#define TFT_DC                  21   
