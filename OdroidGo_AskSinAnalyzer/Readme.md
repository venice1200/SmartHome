Da der OdroidGo die gleiche Hardware mitbringt wie für den AskSinAnalyzer benötigt wird   
ist eine Sketch I/O-Anpassung relativ einfach.   
Nur das OdroidGo Display wird ohne Reset betrieben.   
   
Pin Definition for AskSin Analyzer running on OdroidGo   
   
See https://wiki.odroid.com/odroid_go/odroid_go#odroid-go_gpio_pin_mapping    
and https://wiki.odroid.com/odroid_go/odroid_go#odroid-go_header_p2_description   
...
OdroidGo Schematic   
https://wiki.odroid.com/lib/exe/fetch.php?tok=5d7e2f&media=https%3A%2F%2Fgithub.com%2Fhardkernel%2FODROID-GO%2Fblob%2Fmaster%2FDocuments%2FODROID-GO_REV0.1_20180518.pdf   
   
//Pin definitions for external switches
#define START_WIFIMANAGER_PIN    27  // Button Select LOW = on boot: start wifimanager, on run: switch between tft screens   
#define SHOW_DISPLAY_LINES_PIN   32  // Button A      LOW = show lines between rows   
#define SHOW_DISPLAY_DETAILS_PIN 33  // Button B      LOW = show detailed information on display, HIGH = show only main infos   
#define ONLINE_MODE_PIN          13  // Button Menu   LOW = enable WIFI   
#define RSSI_PEAK_HOLD_MODE_PIN  39  // Button Start  LOW = show peak line only for noisefloor, HIGH = show also for hm(ip) messages   
   
//Pin definition for LED   
#define AP_MODE_LED_PIN          2  // Status LED   
   
//Pin definition for SD Card   
#define SD_CS                    22   
   
//Pin definitions for serial connection to Sniffer   
#define EXTSERIALTX_PIN          15   
#define EXTSERIALRX_PIN          4   
#define EXTSERIALBAUDRATE        57600   
   
//Pin definitions for Display   
#define TFT_LED                 14   
#define TFT_CS                   5   
//#define TFT_RST                 26  // No ESP Pin for TFT Reset connected   
#define TFT_DC                  21   
