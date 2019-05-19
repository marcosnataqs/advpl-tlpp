#Include "Protheus.ch"

/*/{Protheus.doc} LTGetToken

Chave de Acesso da API gerada no Leantrack 4.0 (Menu -> Integrações -> API)

@author 	Marcos Natã Santos
@since 		15/05/2019
@version 	12.1.17
@return 	cAuthToken
/*/
User Function LTGetToken
    Local cAuthToken  := ""

    cAuthToken += "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjIyNDViYjFlZTQxYWFlMmFmZGYzNzk2OGE1M2"
    cAuthToken += "JkYjA0YTA0NWE4MGQ3NjFiYTM1ZDhhYjE4NGEwYTUzM2NjMTgifQ.eyJpc3MiOiJodHRwczpcL1wvZGVtb"
    cAuthToken += "y5sZWFudHJhY2suY29tLmJyIiwiYXVkIjoiaHR0cHM6XC9cL2RlbW8ubGVhbnRyYWNrLmNvbS5iciIsImp"
    cAuthToken += "0aSI6IjIyNDViYjFlZTQxYWFlMmFmZGYzNzk2OGE1M2JkYjA0YTA0NWE4MGQ3NjFiYTM1ZDhhYjE4NGEwY"
    cAuthToken += "TUzM2NjMTgiLCJpYXQiOjE1NTgyNzE3MjQsIm5iZiI6MTU1ODI3MTcyNCwiZXhwIjowLCJzdWIiOiIzMSI"
    cAuthToken += "sInByb3ZpZGVyIjoidXNlcnMiLCJhcGlfa2V5Ijp0cnVlfQ.E43Ehix5e1JXzEo5EIWlCVDbJk1jlxBI-v"
    cAuthToken += "EZpHT4YtgBvoOA0s7tuNpIG-Wp30QGKor67L35LEcO1CsqT02VErnXh1WO5McoiJ7B2PcKpittrkItmdFi"
    cAuthToken += "V3EGzdLVT-gVv-l53Ruz4t5zQ264fmlVI9wcpemZuNdJ4coc_pK8N6XXNZWjvSNaR0_GZrBTcwcowO2RFY"
    cAuthToken += "F1wnBRXGqrDwOVCiIXWDpjuGbVuy2aWezKMAZ8Z7cjzLTndm-DrwfMxxGrFjl2itbuzOJTj0zoEu1p8BXc"
    cAuthToken += "JuXh7Gi85ZqdIDa1YHCouupDznwgA5zoVXoQeNRmtO1Nh0k4QAbSnvKrW3l9-K9WgumXNcuUezhE0osqVq"
    cAuthToken += "qNx806JcuXyex08EbMMsZDOJt-tqeTNizeDKLftOseNaGW2nQ5LdB61v8P648Tugt8ZQMUa_VIcAAs-m4Z"
    cAuthToken += "v2IHXcb5hAH7lLzVjz-nZ8sYpBpE0k0EQl0JBFXqc26oo8Neat_79awe-PEOdIUtuCEgBbU6WJuyrrIywB"
    cAuthToken += "YmVx5g-p1Uh3xCty1T86GRypUlitqt-aEk38e2wIqoJ9KTZkoryoq00odgReTwsQm6m7PRCF6rDpCQ_v2m"
    cAuthToken += "hMIZ4HNHWkuIEN4K94XB9mH695XK-rgOIyVcQXJKHSwz9SQ9TWve4LFxsGcrkBAJLxR54HguSWg"

Return cAuthToken