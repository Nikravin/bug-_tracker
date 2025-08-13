"""
Simple test to verify AI chat bot function calling works
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from routes.ai_chat_bot import execute_function
from unittest.mock import Mock, MagicMock

def test_function_execution():
    """Test that function execution works properly"""
    
    # Mock database session
    mock_db = Mock()
    
    # Mock user data
    mock_user = {"id": "user123", "role": "admin"}
    
    # Mock project objects
    mock_project1 = Mock()
    mock_project1.id = "proj1"
    mock_project1.title = "Test Project 1"
    mock_project1.description = "Description 1"
    mock_project1.created_by = "user123"
    
    mock_project2 = Mock()
    mock_project2.id = "proj2"
    mock_project2.title = "Test Project 2"
    mock_project2.description = "Description 2"
    mock_project2.created_by = "user123"
    
    # Mock query results
    mock_db.query.return_value.filter.return_value.all.return_value = [mock_project1, mock_project2]
    mock_db.query.return_value.filter.return_value.first.return_value = None
    
    # Test function call
    result = execute_function("show_all_projects()", mock_db, mock_user)
    
    print("Function execution test:")
    print(f"Success: {result.get('success')}")
    print(f"Count: {result.get('count')}")
    print(f"Data: {result.get('data')}")
    
    return result.get('success', False)

def test_system_prompt():
    """Test that system prompt is properly formatted"""
    from routes.ai_chat_bot import SYSTEM_PROMPT
    
    print("\nSystem Prompt Test:")
    print("✓ Contains function description" if "show_all_projects" in SYSTEM_PROMPT else "✗ Missing function description")
    print("✓ Contains FUNCTION_CALL instruction" if "FUNCTION_CALL:" in SYSTEM_PROMPT else "✗ Missing FUNCTION_CALL instruction")
    print("✓ Contains example" if "How many projects do I have?" in SYSTEM_PROMPT else "✗ Missing example")

if __name__ == "__main__":
    print("Testing AI Chat Bot Function Calling...\n")
    
    # Test function execution
    success = test_function_execution()
    
    # Test system prompt
    test_system_prompt()
    
    print(f"\nOverall test result: {'✓ PASSED' if success else '✗ FAILED'}")