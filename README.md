# 🛡️ AI Guardian

### Don't just send an SOS. Stay with the user.

**AI Guardian** is a situation-aware AI emergency companion designed to help users respond to dangerous or uncertain situations using voice input, device context, trusted contacts, adaptive emergency modes, and safety guidance.

Built as a prototype for **iQOO Hackathon 2026**.

---

## 👥 Team

### NPC's

**Project:** AI Guardian  
**Hackathon:** iQOO Hackathon 2026  
**Track:** Smart Living  
**Platform:** Android  
**Framework:** Flutter

---

## 🚨 The Problem

During an emergency, people may not have enough time or clarity to decide what action to take.

Traditional SOS systems generally follow a simple flow:

> Detect → Notify

But an emergency can be much more complex.

A person may be:

- Being followed
- In physical danger
- Injured
- Involved in an accident
- Lost in an unfamiliar location
- Running out of battery
- Without network connectivity

In these situations, simply sending an SOS may not be enough.

The user needs a system that can understand the situation and help decide what to do next.

---

## 💡 Our Solution

AI Guardian transforms the traditional emergency button into a **situation-aware emergency companion**.

Instead of simply sending an alert, AI Guardian follows:

> **Understand → Decide → Act → Monitor → Adapt**

The user can describe their situation using voice, and AI Guardian analyzes the situation and combines it with available device context such as:

- 📍 Location
- 🔋 Battery
- 📶 Network
- 🎤 Voice input
- 👥 Trusted contacts

Based on this context, the application provides an adaptive emergency response.

---

## 🧠 How AI Guardian Works

```text
                 USER
                  │
                  ▼
           Voice / Quick SOS
                  │
                  ▼
        ┌──────────────────┐
        │ Speech Recognition│
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Situation Engine │
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Context Analysis │
        │                  │
        │ Location         │
        │ Battery          │
        │ Network          │
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Adaptive Decision│
        │      Layer       │
        └────────┬─────────┘
                 │
                 ▼
       ┌─────────────────────┐
       │ Emergency Assistance │
       │                     │
       │ Call Contact        │
       │ Share Alert         │
       │ AI Guidance         │
       │ Find Safe Place     │
       └─────────────────────┘