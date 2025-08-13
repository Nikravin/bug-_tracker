import ollama
# from fastapi import APIRouter, Depends, HTTPException, status
import json
# from sqlalchemy.orm import Session
# from routes.project_routes import show_all_projects
# from utility.token_genrater import decode_access_token
# from config.db import SessionLocal
# from fastapi.concurrency import run_in_threadpool
# import sys
# import logging

# # Set up logging
# logging.basicConfig(level=logging.DEBUG)
# logger = logging.getLogger(__name__)

# chat_bot = APIRouter()

# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()


import re
from typing import Any

# -------------------------
# Your tool
# -------------------------
def getWeatherDetails(city: str):
    city = city.lower()
    if city == 'patiala':
        return '10°C'
    if city == 'mohali':
        return '14°C'
    if city == 'delhi':
        return '12°C'
    if city == 'bangalore':
        return '20°C'
    if city == 'chandigarh':
        return '8°C'
    return 'Weather data not available'

# -------------------------
# Helpers
# -------------------------
def extract_first_json(text: str) -> str | None:
    """Try to extract a JSON object substring from text (first balanced {...})."""
    # fast check
    try:
        json.loads(text)
        return text
    except Exception:
        pass

    # find balanced braces
    for i, ch in enumerate(text):
        if ch == '{':
            depth = 0
            for j in range(i, len(text)):
                if text[j] == '{':
                    depth += 1
                elif text[j] == '}':
                    depth -= 1
                    if depth == 0:
                        candidate = text[i:j+1]
                        try:
                            json.loads(candidate)
                            return candidate
                        except Exception:
                            break
    return None

def normalize_keys(obj: Any) -> Any:
    """Strip whitespace from dict keys recursively."""
    if isinstance(obj, dict):
        return {k.strip(): normalize_keys(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [normalize_keys(x) for x in obj]
    return obj

def parse_int_from_temp(s: str):
    """Return integer part of '10°C' -> 10, or None if not found."""
    if not isinstance(s, str):
        return None
    m = re.search(r'-?\d+', s)
    return int(m.group()) if m else None

# -------------------------
# System prompt: ask model to output ONLY the plan JSON
# -------------------------
SYSTEM_PROMPT = """
You are a utility that extracts the user's intent and the list of cities to query.
You MUST respond only with a JSON object (no extra text) in this exact shape:

{
  "type": "plan",
  "cities": ["city1", "city2", ...],
  "intent": "list" | "sum"
}

- "cities" must be an array of city names (strings). If a single city, return a one-item array.
- "intent" = "list" (user wants each city's weather) or "sum" (user asked to add temperatures).
- If uncertain about sum vs list, default to "list".
- Do not include weather values; only tell which cities to query.
Example:
{"type":"plan","cities":["patiala","mohali"],"intent":"sum"}
"""

# -------------------------
# Main loop
# -------------------------
messages = [{"role": "system", "content": SYSTEM_PROMPT}]

print("AI Agent running (type 'quit' or 'exit' to stop)...\n")

while True:
    user_text = input("User: ").strip()
    if user_text.lower() in ("exit", "quit"):
        break

    # send user message
    messages.append({"role": "user", "content": user_text})

    # Ask the model to produce plan JSON
    plan = None
    max_retries = 3
    for attempt in range(max_retries):
        chat = ollama.chat(
            model="llama3.1:8b",
            messages=messages,
            format="json"
        )
        raw = chat["message"]["content"]
        # try parse JSON directly, else try extract substring
        parsed = None
        try:
            parsed = json.loads(raw)
        except Exception:
            candidate = extract_first_json(raw)
            if candidate:
                try:
                    parsed = json.loads(candidate)
                except Exception:
                    parsed = None

        if not parsed:
            # ask model to retry in JSON-only format
            messages.append({
                "role": "developer",
                "content": json.dumps({
                    "type": "error",
                    "error": "Please return valid JSON only in the required plan format."
                })
            })
            continue

        parsed = normalize_keys(parsed)
        # validate structure
        if parsed.get("type") != "plan" or not parsed.get("cities"):
            messages.append({
                "role": "developer",
                "content": json.dumps({
                    "type": "error",
                    "error": "Expecting type=plan and a non-empty cities list. Retry."
                })
            })
            continue

        plan = parsed
        # append assistant's content so chat history has it (keeps context)
        messages.append({"role": "assistant", "content": json.dumps(parsed)})
        break  # got a valid plan

    if plan is None:
        print("Failed to get a valid plan from the model after retries. Please rephrase.")
        continue

    # normalize cities list
    cities = plan.get("cities")
    if isinstance(cities, str):
        cities = [cities]
    cities = [c.strip() for c in cities if isinstance(c, str) and c.strip()]

    if not cities:
        print("No cities parsed. Please rephrase your question.")
        continue

    # call tool for each city and collect observations
    observations = {}
    numeric_temps = {}
    for c in cities:
        obs = getWeatherDetails(c)
        observations[c] = obs
        numeric = parse_int_from_temp(obs)
        numeric_temps[c] = numeric

    # build final output here (guaranteed correct because we used the tool)
    intent = plan.get("intent", "list")
    if intent == "sum":
        nums = [v for v in numeric_temps.values() if v is not None]
        if nums:
            total = sum(nums)
            final = f"The sum of temperatures for {', '.join([c.title() for c in cities])} is {total}°C."
        else:
            final = f"No numeric temperature available to sum for the requested cities: {', '.join([c.title() for c in cities])}."
    else:
        # "list" intent
        parts = [f"{c.title()}: {observations[c]}" for c in cities]
        final = " ; ".join(parts)

    # print final answer (this comes from our code, not the LLM)
    print("Bot:", final)

    # add a final assistant message (so the model sees we completed the action)
    messages.append({"role": "assistant", "content": json.dumps({"type": "output", "output": final})})


#CLAUDE CODE WITH MULTI CITY OPERATION AND COMPARISON AND THIS CODE IS FULLY FUNCTIONAL

# import re
# from typing import Optional, Dict, Any, List

# class WeatherAIAgent:
#     def __init__(self):
#         self.model = "llama3.1:8b"
#         self.available_cities = ['patiala', 'mohali', 'delhi', 'bangalore', 'chandigarh']
        
#         # Enhanced system prompt for multi-city operations
#         self.system_prompt = """
# You are a helpful weather assistant AI agent with function calling abilities.

# Available functions:
# 1. getWeatherDetails(city) - Gets weather for a single city
# 2. calculateWeatherSum(cities) - Calculates sum of temperatures for multiple cities
# 3. compareWeatherData(cities) - Compares weather across multiple cities

# When users ask about weather, analyze their request and respond with JSON:

# For single city weather:
# {"function_call": "getWeatherDetails", "city": "cityname", "reasoning": "explanation"}

# For weather calculations (sum, total, add):
# {"function_call": "calculateWeatherSum", "cities": ["city1", "city2"], "reasoning": "explanation"}

# For weather comparisons (compare, difference, which is warmer):
# {"function_call": "compareWeatherData", "cities": ["city1", "city2"], "reasoning": "explanation"}

# For invalid requests:
# {"function_call": "none", "message": "helpful response", "reasoning": "explanation"}

# Available cities: Patiala, Mohali, Delhi, Bangalore, Chandigarh

# Examples:
# "What's the weather in Delhi?" → {"function_call": "getWeatherDetails", "city": "delhi", "reasoning": "Single city query"}

# "What is the sum of weather in Patiala and Bangalore?" → {"function_call": "calculateWeatherSum", "cities": ["patiala", "bangalore"], "reasoning": "User wants to add temperatures"}

# "Compare weather in Delhi and Mohali" → {"function_call": "compareWeatherData", "cities": ["delhi", "mohali"], "reasoning": "User wants to compare temperatures"}

# Rules:
# - Extract ALL mentioned cities
# - Always use lowercase city names in JSON
# - For sum/total/add operations, use calculateWeatherSum
# - For compare/difference operations, use compareWeatherData
# - Return valid JSON only
# """

#     def getWeatherDetails(self, city: str) -> str:
#         """Get weather for a single city"""
#         city = city.lower()
#         weather_data = {
#             'patiala': '10°C',
#             'mohali': '14°C', 
#             'delhi': '12°C',
#             'bangalore': '20°C',
#             'chandigarh': '8°C'
#         }
#         return weather_data.get(city, 'Weather data not available')

#     def extract_temperature_value(self, temperature_str: str) -> Optional[int]:
#         """Extract numeric value from temperature string like '10°C'"""
#         try:
#             return int(temperature_str.replace('°C', '').strip())
#         except (ValueError, AttributeError):
#             return None

#     def calculateWeatherSum(self, cities: List[str]) -> str:
#         """Calculate sum of temperatures for multiple cities"""
#         if not cities:
#             return "No cities provided for calculation"
            
#         results = []
#         total = 0
#         valid_cities = []
        
#         print(f"🧮 Calculating sum for cities: {cities}")
        
#         for city in cities:
#             city_lower = city.lower().strip()
#             weather = self.getWeatherDetails(city_lower)
#             temp_value = self.extract_temperature_value(weather)
            
#             if temp_value is not None:
#                 results.append(f"{city_lower.capitalize()}: {weather}")
#                 total += temp_value
#                 valid_cities.append(city_lower.capitalize())
#             else:
#                 results.append(f"{city_lower.capitalize()}: Data not available")
        
#         if valid_cities:
#             result_text = "\n".join(results)
#             result_text += f"\n\n🧮 Sum of temperatures: {total}°C"
#             result_text += f"\n📊 Cities included: {', '.join(valid_cities)}"
#             return result_text
#         else:
#             return "❌ No valid temperature data found for the specified cities"

#     def compareWeatherData(self, cities: List[str]) -> str:
#         """Compare weather data across multiple cities"""
#         if len(cities) < 2:
#             return "Need at least 2 cities for comparison"
            
#         print(f"📊 Comparing weather for cities: {cities}")
        
#         city_temps = {}
#         results = []
        
#         for city in cities:
#             city_lower = city.lower().strip()
#             weather = self.getWeatherDetails(city_lower)
#             temp_value = self.extract_temperature_value(weather)
            
#             if temp_value is not None:
#                 city_temps[city_lower.capitalize()] = temp_value
#                 results.append(f"{city_lower.capitalize()}: {weather}")
        
#         if len(city_temps) < 2:
#             return "❌ Need at least 2 valid cities for comparison"
        
#         # Find hottest and coldest
#         hottest_city = max(city_temps, key=city_temps.get)
#         coldest_city = min(city_temps, key=city_temps.get)
        
#         result_text = "\n".join(results)
#         result_text += f"\n\n🌡️ Comparison Results:"
#         result_text += f"\n🔥 Hottest: {hottest_city} ({city_temps[hottest_city]}°C)"
#         result_text += f"\n🧊 Coldest: {coldest_city} ({city_temps[coldest_city]}°C)"
#         result_text += f"\n📏 Temperature difference: {city_temps[hottest_city] - city_temps[coldest_city]}°C"
        
#         return result_text

#     def extract_cities_fallback(self, query: str) -> List[str]:
#         """Fallback method to extract multiple cities using regex"""
#         query_lower = query.lower()
#         found_cities = []
        
#         # Direct city mentions
#         for city in self.available_cities:
#             if city in query_lower:
#                 found_cities.append(city)
        
#         return found_cities

#     def determine_operation_fallback(self, query: str) -> str:
#         """Determine what operation user wants using keywords"""
#         query_lower = query.lower()
        
#         sum_keywords = ['sum', 'total', 'add', 'addition', 'plus', '+']
#         compare_keywords = ['compare', 'comparison', 'difference', 'diff', 'warmer', 'colder', 'hotter']
        
#         if any(keyword in query_lower for keyword in sum_keywords):
#             return "calculateWeatherSum"
#         elif any(keyword in query_lower for keyword in compare_keywords):
#             return "compareWeatherData"
#         else:
#             return "getWeatherDetails"

#     def call_llm(self, messages: list) -> Optional[Dict[str, Any]]:
#         """Make a call to the LLM with error handling"""
#         try:
#             response = ollama.chat(
#                 model=self.model,
#                 messages=messages,
#                 format='json',
#                 options={
#                     'temperature': 0.1,
#                     'top_p': 0.9,
#                     'repeat_penalty': 1.1
#                 }
#             )
            
#             content = response["message"]["content"].strip()
            
#             try:
#                 return json.loads(content)
#             except json.JSONDecodeError:
#                 print(f"⚠️ Invalid JSON from LLM: {content}")
#                 return None
                
#         except Exception as e:
#             print(f"❌ Error calling LLM: {e}")
#             return None

#     def process_query(self, user_query: str) -> str:
#         """Process user query and return response"""
#         print(f"🤔 Processing: '{user_query}'")
        
#         messages = [
#             {"role": "system", "content": self.system_prompt},
#             {"role": "user", "content": user_query}
#         ]
        
#         # Try LLM first
#         llm_response = self.call_llm(messages)
        
#         if llm_response and "function_call" in llm_response:
#             function_call = llm_response["function_call"]
#             reasoning = llm_response.get("reasoning", "")
#             print(f"🧠 LLM Reasoning: {reasoning}")
            
#             if function_call == "getWeatherDetails":
#                 city = llm_response.get("city", "").lower()
#                 print(f"🔧 Calling: getWeatherDetails('{city}')")
#                 weather_result = self.getWeatherDetails(city)
                
#                 if weather_result == "Weather data not available":
#                     return f"❌ Sorry, I don't have weather data for '{city}'. Available cities: {', '.join(self.available_cities)}"
#                 else:
#                     return f"🌡️ The weather in {city.capitalize()} is {weather_result}"
            
#             elif function_call == "calculateWeatherSum":
#                 cities = llm_response.get("cities", [])
#                 print(f"🔧 Calling: calculateWeatherSum({cities})")
#                 return self.calculateWeatherSum(cities)
            
#             elif function_call == "compareWeatherData":
#                 cities = llm_response.get("cities", [])
#                 print(f"🔧 Calling: compareWeatherData({cities})")
#                 return self.compareWeatherData(cities)
            
#             elif function_call == "none":
#                 message = llm_response.get("message", "I couldn't understand your request.")
#                 return f"ℹ️ {message}"
        
#         # Fallback to regex extraction if LLM fails
#         print("🔄 LLM failed, using fallback method...")
#         cities = self.extract_cities_fallback(user_query)
#         operation = self.determine_operation_fallback(user_query)
        
#         if cities:
#             print(f"🎯 Fallback found cities: {cities}, operation: {operation}")
            
#             if operation == "calculateWeatherSum" and len(cities) >= 2:
#                 return self.calculateWeatherSum(cities)
#             elif operation == "compareWeatherData" and len(cities) >= 2:
#                 return self.compareWeatherData(cities)
#             elif len(cities) == 1:
#                 weather_result = self.getWeatherDetails(cities[0])
#                 return f"🌡️ The weather in {cities[0].capitalize()} is {weather_result}"
#             else:
#                 # Multiple cities but unclear operation
#                 if len(cities) > 1:
#                     return f"🤔 I found multiple cities: {', '.join([c.capitalize() for c in cities])}. Would you like me to compare them or calculate their sum?"
        
#         return f"❓ I couldn't identify cities in your query. Available cities: {', '.join([city.capitalize() for city in self.available_cities])}"

#     def chat_loop(self):
#         """Main chat loop for the AI agent"""
#         print("🤖 Enhanced Weather AI Agent Started!")
#         print(f"📍 Available cities: {', '.join([city.capitalize() for city in self.available_cities])}")
#         print("🧮 I can handle single weather queries, calculations, and comparisons!")
#         print("💬 Examples:")
#         print("   - 'What's the weather in Delhi?'")
#         print("   - 'What is the sum of weather in Patiala and Bangalore?'")
#         print("   - 'Compare weather in Delhi and Mohali'")
#         print("   - 'Which is warmer, Bangalore or Chandigarh?'")
#         print("\nType 'quit' to exit.\n")
        
#         while True:
#             try:
#                 user_input = input("You: ").strip()
                
#                 if user_input.lower() in ['quit', 'exit', 'bye']:
#                     print("👋 Goodbye! Thanks for using Weather AI Agent!")
#                     break
                
#                 if not user_input:
#                     print("Please enter a query or 'quit' to exit.")
#                     continue
                
#                 # Process the query
#                 response = self.process_query(user_input)
#                 print(f"Agent: {response}\n")
                    
#             except KeyboardInterrupt:
#                 print("\n👋 Goodbye!")
#                 break
#             except Exception as e:
#                 print(f"❌ Unexpected error: {e}")

# def main():
#     """Main function to run the Weather AI Agent"""
#     try:
#         # Check if Ollama is available
#         models = ollama.list()
#         print(f"✅ Connected to Ollama. Available models: {len(models['models'])}")
        
#         # Initialize and start the agent
#         agent = WeatherAIAgent()
#         agent.chat_loop()
        
#     except Exception as e:
#         print(f"❌ Error initializing: {e}")
#         print("Make sure Ollama is running and llama3.1:8b model is available.")

# if __name__ == "__main__":
#     main()