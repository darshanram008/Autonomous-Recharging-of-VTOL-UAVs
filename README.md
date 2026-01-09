# Autonomous-Recharging-of-VTOL-UAVs
A novel way of recharging UAVs and VTOL to extend operational time, design consist of a charging pad that can be mounted on streetlight poles, algorithms for landing and resuming mission based on available state of charge

# 🚁 Autonomous UAV Recharging System  

This project implements a concpet demonstartion of a fully autonomous workflow where a multirotor UAV can **detect low battery**, **navigate to a charging pad**, **land precisely**, **recharge**, and **resume its mission** without human intervention.  
The concept protoype is implemnetd on a F450  drone frame, carrying a Pixhawk with ArduPilot firmware and landing algorithms running on Lua scripts, the charging pad has contacts instead of wireless charging to reduce energy wastage and improve the speed of the charging (😅 Its a silly idea but has its own advantage). 
This work is published in *Cogent Engineering (2025)😄*.  
**DOI:** https://doi.org/10.1080/23311916.2025.2490529
The presentation and video demonstartion can be found [here](https://www.canva.com/design/DAFaGJnR2SM/KS8v1EFg4Ng5H95vCfM0ig/edit?utm_content=DAFaGJnR2SM&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

---

## 📌 Overview
UAVs suffer from limited flight time and it reduces exponentially with increase in payload, as UAVs will be used extensively in future for logistic delivery operations this project aims to solve the problem by enabling them to autonomously: 
- Monitor **State of Charge (SoC)**
- Decide when to recharge based on its current position, nearest charging pad position and intended destination. 
- Navigate to the nearest charging pad
- Perform **GPS‑guided landing** (🥲 not accurate but use of computer vision is also discussed later) 
- Charge via a **universal contact‑based pad**
- Automatically resume the mission

The charging pads are designed for **streetlight pole mounting**,that make use of their even spacing and obstacle free environemnt for hassle free deployment as seperate power lines or poles need not be built to accomodate the UAVs

---

## 🧠 Key Features

### 🔹 GPS‑Guided Autonomous Landing
- Pixhawk + ArduPilot navigation  
- Achieved **~0.5 m landing accuracy** in real flight tests  
- With ArUco Markers (black and white fiducial markers) on the pads the accuracy can be bought to cm range
- A downward facing camera on the drone can be used to detect the marker and compute
    - X/Y offset
    - Altitude (Z)
    - Yaw alignment
    - Position relative to the pad
    

### 🔹 SoC‑Based Mission Logic
- Lua scripts estimate SoC using **coulomb counting**  
- Drone computes remaining flight range  
- Diverts to charging pad if battery is insufficient  
- Automatically resumes mission after charging  

### 🔹 Universal Contact‑Based Charging Pad
- 2‑meter pad designed for streetlight poles  
- Grooved contacts prevent rain short circuits  
- Servo mechanism corrects polarity  
- NFC tag transfers battery metadata (mAh, voltage, cell count)
- 

### 🔹 Custom AC‑DC Charger Hardware
- 150 W output (24 V, 6 A)  
- **PFC stage** using FAN7930B (CRM mode)  
- **Flyback converter** using UCC2871x  
- **LDO regulation** using LD1084  
- Designed for high efficiency and low harmonic distortion  

### 🔹 SITL Simulation + Real Flight Testing
- Mission planning via Mission Planner  
- SITL accuracy: **~0.1 m**  
- Real‑world accuracy: **~0.5 m**  
- Verified autonomous land‑charge‑resume workflow  

---

## 🛠️ System Architecture

---

## 🔧 Technical Stack

### **Embedded & Autonomy**
- Pixhawk 2.4.6  
- ArduPilot (ArduCopter)  
- Lua scripting  
- MAVLink  
- SITL simulation  

### **Power Electronics**
- FAN7930B (PFC controller)  
- UCC2871x (flyback controller)  
- LD1084 (LDO regulator)  
- AC‑DC charger design (150 W)

### **Hardware**
- Custom charging pad  
- Aluminum contact plates  
- Servo polarity correction  
- NFC tag for battery metadata  

### **Software Tools**
- Mission Planner  
- KiCad 


---

## 📊 Results

| Metric | Result |
|--------|--------|
| Landing accuracy (real flight) | **~0.5 m** |
| Landing accuracy (SITL) | **~0.1 m** |
| Charger output | **24 V, 6 A (150 W)** |
| SoC estimation error | **< 5%** |
| Successful autonomous cycles | **5+ test flights** |

---

<!-- ## 📁 Repository Structure -->

---

## 🧑‍💻 Author

[Darshan R](https://github.com/darshanram008) and [prateek N](https://github.com/miscellaneous-mice)

