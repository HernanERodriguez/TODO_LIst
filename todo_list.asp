<body>

<h1>TODO LIST</h1>

    <form method="post" action="todo_list.asp">
        <label>Tarea:</label><br>
        <textarea maxlength="250" placeholder="Ingrese la descripcion de la tarea a insertar o actualizar" name="tarea" style="width: 300px; height: 100px;"></textarea><br>
        <input type="submit" name="add" value="Agregar/Actualizar">
        <br><br><br>
    

<%

'Conexión BBDD
Dim objConn
Set objConn = Server.CreateObject("ADODB.Connection")
'objConn.ConnectionString = "Provider=SQLNCLI; Data Source=.; Initial Catalog=TodoList; User ID=tdl_app; Password=tdl_app"
objConn.ConnectionString = "Provider=sqloledb; Data Source=localhost\SQLEXPRESS; Initial Catalog=TodoList; User ID=tdl_app; Password=tdl_app"
objConn.Open



Dim SQL

'Recorro los items que llegaron en el POST del FORM
For Each Item In Request.Form
    
    'Si se marcó como completada, actualizo el flag en BBDD
    IF Left(Item,3) = "chk" THEN
        id = MID(Item,4)
        strSQL = "UPDATE Notas SET Finalizada = 1 WHERE Id = " & id 
        objConn.Execute(strSQL)
    'Si se actualizó, tomo el nuevo valor del textarea y lo actualizo en BBDD
    ElseIf Left(Item,3) = "upd" THEN
        IF request.form("tarea") <> "" THEN
            id = MID(Item,4)
            strSQL = "UPDATE Notas SET Texto = '" & request.form("tarea") & "' WHERE Id = " & id 
            objConn.Execute(strSQL)
        Else
            response.write("<h3>Se debe informar un nuevo valor para la tarea HHH</h3>")
        End if
    'Si se eliminó, mando el DELETE a la BBDD
    ElseIf Left(Item,3) = "del" THEN
        id = MID(Item,4)
        strSQL = "DELETE FROM Notas WHERE Id = " & id 
        objConn.Execute(strSQL)
    'Si se está agregando, inserto en BBDD
    ElseIf Left(Item,3) = "add" THEN
        IF request.form("tarea") <> "" THEN
            SQL = "INSERT INTO Notas (Texto, Finalizada) VALUES ('" & request.form("tarea") & "',0)"
            objConn.Execute SQL
        Else
            response.write("<h3>Se debe informar un nuevo valor para la tarea HH</h3>")
        End if
    End if
Next

'Recupero las tareas vigentes para la primer lista
dim strSQL
strSQL = "SELECT Id, Texto, Finalizada FROM Notas WHERE Finalizada = 0 ORDER BY Texto"
Set rst = objConn.Execute(strSQL)


Response.Write("<table style='width: auto; height: auto;'><caption>Tareas pendientes</caption>")
'Si no hay pendientes, dejo el mensaje
If rst.BOF And rst.EOF Then
    Response.Write("<tr><td>Sin notas pendientes</td></tr>")
'Armo la tabla en base a las tareas pendintes y agrego los controles para finalizar, actualizar y eliminar
Else
    Do While (Not rst.EOF)
    Response.Write "<tr>" &_
    "<td></td>" &_
    "<td>" & rst("Texto") & "</td>" &_
    "<td><input type='checkbox' name='chk" & rst("Id") & "' onclick=submit()><td>" &_
    "<td><input type='submit'   name='upd" & rst("Id") & "' onclick=submit() value='Actualizar'<td>" &_
    "<td><input type='submit'   name='del" & rst("Id") & "' onclick=submit() value='Eliminar'  <td>" &_
    "</tr>"
    rst.MoveNext
    Loop
End If
Response.Write("</table>")



strSQL = "SELECT Id, Texto, Finalizada FROM Notas WHERE Finalizada = 1 ORDER BY Texto"
Set rst = objConn.Execute(strSQL)

Response.Write("<br><br><br><table style='width: 300px; height: auto;'><caption>Tareas finalizadas</caption>")
'Si no hay finalizadas, dejo el mensaje
If rst.BOF And rst.EOF Then
    Response.Write("<tr><td>Sin notas pendientes</td></tr>")
'Armo la tabla en base a las tareas finalizadas
Else
    Do While (Not rst.EOF)
    Response.Write "<tr><td>" & rst("Texto") & "</td></tr>"
    rst.MoveNext
    Loop
End If
Response.Write("</table>")


objConn.Close
%>
</form>
</body>