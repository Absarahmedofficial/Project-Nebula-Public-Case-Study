# ProcMon Filter Recipe
Include: Process Name is <App>.exe
Include: RegCreateKey, RegSetValue, WriteFile
Include: Path contains `Data.db`
Exclude: System noise providers
