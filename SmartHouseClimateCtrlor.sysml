package SmartHouseClimateCtrlorSystem{
    package Definitions{
        package System{
            part def TemperatureSensor{
                attribute EnvTemperature;
                action MeasureTemperature;
            }
            part def HumiditySensor{
                attribute EnvHumidity;
                action MeasureHumidity;
            }
            part def ClimateController{
                ref part TemperatureSensor;
                ref part HumiditySensor;
                attribute TemperatureThreshold;
                attribute HumidityThreshold;
                action AdjustClimate{
                    in EnvHumidity;
                    in EnvTemperature;
                    out ControlSignal;
                }
            }
            part def UserInterface{
                action DisplayCurrentConditions;
                action SetPreferences;
            }
        }
    }
    use case 'use system'{
        import Definitions::*;
        subject system : System;
        actor user : User{
            action StartClimateControl;
            action StopClimateControl;
            action SetTemperaturePreference;
            action ViewCurrentConditions;
        }
    }
    package actions{
        import Definitions::*;
        action def ClimateControlProcess{
            import Definitions::*;
            first StartControl;
            then merge continueMonitoring;
            action humiditySensor : HumiditySensor{
                out envHumidity : Real;
            }
            action temperatureSensor : TemperatureSensor{
                out envTemperature : Real;
            }
            then decide;
            if humiditySensor.envHumidity > humidityUpperBound or humiditySensor.envHumidity < humidityLowerBound 
                or temperatureSensor.envTemperature > temperatureUpperBound or temperatureSensor.envTemperature < temperatureLowerBound then adjustClimate;
            else continueMonitoring;
            action adjustClimate : AdjustClimate{}
            then continueMonitoring;
        }

    }
    state def SystemStates{
        entry; then Idle;
        state Idle;
        transition idle_to_monitoring
            first Idle
            accept startButtonPressed
            then Monitoring;
        state Monitoring;
        transition monitoring_to_adjusting1
            first Monitoring
            accept temperatureThresholdExceeded
            then Adjusting;
        state Adjusting;
        transition monitoring_to_adjusting2
            first Monitoring
            accept humidityThresholdExceeded
            then Adjusting;
        transition adjusting_to_monitoring
            first Adjusting
            accept temperatureAndHumidityUnderThreshold
            then Monitoring;
        transition adjusting_to_idle
            first Adjusting
            accept stopButtonPressed
            then Idle;
        transition monitoring_to_idle
            first Monitoring
            accept stopButtonPressed
            then Idle;
    }
}