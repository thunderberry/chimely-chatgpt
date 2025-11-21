# Proposed tool schemas

These JSON schema sketches are intended for the ChatGPT Apps SDK manifest. They mirror the existing timer configuration model.

## `create_timer`
```json
{
  "name": "create_timer",
  "description": "Create or update the active timer with duration, interval, and chime options.",
  "parameters": {
    "type": "object",
    "required": ["durationSeconds"],
    "properties": {
      "durationSeconds": {"type": "integer", "minimum": 1},
      "intervalSeconds": {"type": "integer", "minimum": 0, "description": "0 disables interval chimes."},
      "penultimateCue": {"type": "boolean", "default": true},
      "vibrateOnly": {"type": "boolean", "default": false},
      "note": {"type": "string", "description": "Optional task or focus note."}
    }
  }
}
```

## `control_timer`
```json
{
  "name": "control_timer",
  "description": "Control the active timer lifecycle.",
  "parameters": {
    "type": "object",
    "required": ["action"],
    "properties": {
      "action": {"type": "string", "enum": ["start", "pause", "resume", "stop", "reset"]}
    }
  }
}
```

## `get_timer_status`
```json
{
  "name": "get_timer_status",
  "description": "Return the current timer state, including progress and next chime timing.",
  "parameters": {"type": "object", "properties": {}}
}
```

## `list_history`
```json
{
  "name": "list_history",
  "description": "Fetch recent timer sessions.",
  "parameters": {
    "type": "object",
    "properties": {
      "limit": {"type": "integer", "minimum": 1, "maximum": 50, "default": 10}
    }
  }
}
```

## `schedule_timer`
```json
{
  "name": "schedule_timer",
  "description": "Schedule a timer to start later or on a recurring cadence.",
  "parameters": {
    "type": "object",
    "required": ["startAt"],
    "properties": {
      "startAt": {"type": "string", "format": "date-time"},
      "repeatRule": {"type": "string", "enum": ["none", "daily", "weekly"]},
      "payload": {"type": "object", "description": "Timer parameters to apply when the schedule fires."}
    }
  }
}
```
