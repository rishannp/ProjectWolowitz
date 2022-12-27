/**
 * @file PWMServoDriverBase.h
 *
 * class for Adafruit 16 channel pwm driver
 *
 */

#include "LibraryBase.h"
#include "Adafruit_PWMServoDriver.h"
//#include "utility/Adafruit_MS_PWMServoDriver.h"

#define MIN_I2C 0x40
//#define MAX_I2C 0x7F

#ifdef MW_UNO_SHIELDS
#define MAX_SHIELDS 4
#else
#define MAX_SHIELDS 32
#endif

#define MAX_SERVO 16

Adafruit_PWMServoDriver *AFSS[MAX_SHIELDS];
//Adafruit_ServoMotor *ServoMotors[MAX_SHIELDS][MAX_SERVO];
        
// Arduino trace commands
const char MSG_AFSS_CREATE_MOTOR_SHIELD[]        PROGMEM = "Adafruit::AFSS[%d] = new Adafruit_PWMServoDriver(%d)->begin();\n";
const char MSG_AFSS_DELETE_MOTOR_SHIELD[]        PROGMEM = "Adafruit::delete AFSS[%d];\n";

// const char MSG_AFSS_CREATE_SERVO_MOTOR[]         PROGMEM = "Adafruit::AFSS[%d]->getMotor(%d);\n";
const char MSG_AFSS_SET_PWM_SERVO_MOTOR[]        PROGMEM = "Adafruit::AFSS[%d]->setPWM(%d,%d,%d);\n";

#define CREATE_MOTOR_SHIELD 0x00
#define DELETE_MOTOR_SHIELD 0x01
#define SET_PWM_SERVO_MOTOR 0x02
//#define SET_PWM_FREQ_SHIELD 0x04

class AdafruitMotorShieldTrace {
public:
    // motorshield
    static void createMotorShield(byte shieldnum, byte i2caddress, unsigned int pwmfreq) {
        if(shieldnum < MAX_SHIELDS){
            if (NULL != AFSS[shieldnum]) {
                delete(AFSS[shieldnum]);
                AFSS[shieldnum] = NULL;
            }
            AFSS[shieldnum] = new Adafruit_PWMServoDriver(i2caddress);
            AFSS[shieldnum]->begin();
            debugPrint(MSG_AFSS_CREATE_MOTOR_SHIELD, shieldnum, i2caddress, pwmfreq);
        }
    }
    
    static void deleteMotorShield(byte shieldnum) {
        if(shieldnum < MAX_SHIELDS){
            delete AFSS[shieldnum];
            AFSS[shieldnum] = NULL;
            debugPrint(MSG_AFSS_DELETE_MOTOR_SHIELD, shieldnum);
        }
    }
    
    static void setPWM(byte shieldnum, byte motornum, unsigned int freqOn, unsigned int freqOff) {
    if(shieldnum < MAX_SHIELDS){
            AFSS[shieldnum]->setPWM(motornum,freqOn,freqOff);
            debugPrint(MSG_AFSS_SET_PWM_SERVO_MOTOR, shieldnum, motornum, shieldnum, freqOn, freqOff);
        }
    }
    
    /////////////////////////////////////////////////////////////////
};

class PWMServoDriverBase : public LibraryBase
{
	public:
		PWMServoDriverBase(MWArduinoClass& a)
		{
            libName = "Adafruit/PWMServoDriver";
			a.registerLibrary(this);
		}
        
        void setup(){
            for (int i = 0; i < MAX_SHIELDS; ++i) {
                AFSS[i] = NULL;
            }
        }
		
	// Implementation of LibraryBase
	//
	public:
		void commandHandler(byte cmdID, byte* dataIn, unsigned int payloadSize)
		{
            switch (cmdID){//////////////////////////////////////////////////////////////////////////switch comandi
                // Motor shield
                case CREATE_MOTOR_SHIELD:{
                    byte shieldnum = dataIn[0];
                    byte i2caddress = dataIn[1];
                    unsigned int pwmfreq = dataIn[2]+(dataIn[3]<<8);
                    AdafruitMotorShieldTrace::createMotorShield(shieldnum, i2caddress, pwmfreq);
                    
                    sendResponseMsg(cmdID, 0, 0);
                    break;
                }
                case DELETE_MOTOR_SHIELD:{ 
                    byte shieldnum = dataIn[0];
                    
                    AdafruitMotorShieldTrace::deleteMotorShield(shieldnum);
                            
                    sendResponseMsg(cmdID, 0, 0);
                    break;
                }
                case SET_PWM_SERVO_MOTOR:{ 
                    byte shieldnum = dataIn[0];
                    byte motornum = dataIn[1];
                    unsigned int freqOn = dataIn[2];
                    unsigned int freqOff = dataIn[3];
                    
                    AdafruitMotorShieldTrace::setPWM(shieldnum, motornum,freqOn,freqOff);
                            
                    sendResponseMsg(cmdID, 0, 0);
                    break;
                }
                default:
					break;
            }
		}
};