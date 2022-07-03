codeunit 50103 "XML Document Managment"
{

    trigger OnRun()
    begin
        //CreateSampleXmlDocument();//Sample XML creation
        //ExportItemToXMLUsingXMLDocument();
        ImportCustomerFromXMLUsingXMLDocument();
    end;

    local procedure ExportItemToXMLUsingXMLDocument()
    var
        Item: Record Item;
        TempBlob: Codeunit "Temp Blob";
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;
        xmlRootElem: XmlElement;
        xmlParentElem: XmlElement;
        xmlChildElem: XmlElement;
        xmlTxt: XmlText;
        FileName: Text;
        WriteText: Text;
        InStreamL: InStream;
        OutStramL: OutStream;
    begin
        xmlDoc := xmlDocument.Create();
        xmlRootElem := xmlElement.Create('Items');
        XmlDoc.Add(xmlRootElem);

        Item.SetLoadFields("No.", Description, Inventory);
        Item.SetAutoCalcFields(Inventory);
        if Item.FindSet() then
            repeat
                xmlParentElem := XmlElement.Create('Item');
                xmlParentElem.SetAttribute('No.', Item."No.");
                xmlRootElem.Add(xmlParentElem);

                xmlChildElem := XmlElement.Create('Description');
                xmlChildElem.Add(XmlText.Create(Item.Description));
                xmlParentElem.Add(xmlChildElem);

                xmlChildElem := XmlElement.Create('Inventory');
                xmlChildElem.Add(XmlText.Create(Format(Item.Inventory)));
                xmlParentElem.Add(xmlChildElem);
            until Item.Next() = 0;

        TempBlob.CreateOutStream(OutStramL);
        TempBlob.CreateInStream(InStreamL);
        XmlDoc.WriteTo(OutStramL);
        OutStramL.WriteText(WriteText);
        InStreamL.ReadText(WriteText);
        FileName := 'Item.xml';
        DownloadFromStream(InStreamL, '', '', '', FileName);
    end;

    local procedure CreateSampleXmlDocument()
    var
        xmlElem2: XmlElement;
        xmlElem3: XmlElement;
        xmlElem: XmlElement;
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;
        XmlResult: Text;
    begin
        //Create the doc
        xmlDoc := xmlDocument.Create();

        //Add the declaration
        xmlDec := xmlDeclaration.Create('1.0', 'utf-8', 'yes');
        xmlDoc.SetDeclaration(xmlDec);

        //Create root node
        xmlElem := xmlElement.Create('DemoXMLFile');

        //Add some attributes to the root node
        xmlElem.SetAttribute('attribute1', 'value1');
        xmlElem.SetAttribute('attribute2', 'value2');

        //Add DataItems
        xmlElem2 := XmlElement.Create('DataItems');

        //Add a couple of DataItem 
        xmlElem3 := XmlElement.Create('DataItem');
        //Add text to the dataitem
        xmlElem3.Add(XmlText.Create('textvalue'));

        //Write elements to the doc
        xmlElem2.Add(xmlElem3);
        xmlElem.Add(xmlElem2);
        XmlDoc.Add(xmlElem);

        XmlDoc.WriteTo(XmlResult);
        Message(XmlResult);
    end;

    local procedure ImportCustomerFromXMLUsingXMLDocument()
    var
        Customer: Record Customer;
        xmlDoc: XmlDocument;
        xmlRootElem: XmlElement;
        xmlParentElem: XmlElement;
        xmlChildElem: XmlElement;
        xmlParentNodeLst: XmlNodeList;
        xmlParentNode: XmlNode;
        xmlChildNodeLst: XmlNodeList;
        xmlChildNode: XmlNode;
        Filename: Text;
        Instr: InStream;
    begin
        if UploadIntoStream('Select File to Upload', '', '', Filename, Instr) then
            XmlDocument.ReadFrom(Instr, xmlDoc)
        else
            Error('Error in loading a file');

        if xmlDoc.GetRoot(xmlRootElem) then
            xmlParentNodeLst := xmlRootElem.GetChildElements();

        foreach xmlParentNode in xmlParentNodeLst do begin
            Customer.Init();
            xmlParentElem := xmlParentNode.AsXmlElement();
            xmlChildNodeLst := xmlParentElem.GetChildElements();
            foreach xmlChildNode in xmlChildNodeLst do begin
                case xmlChildNode.AsXmlElement().Name of
                    'No.':
                        Customer.Validate("No.", xmlChildNode.AsXmlElement().InnerText);
                    'Name':
                        Customer.Validate("No.", xmlChildNode.AsXmlElement().InnerText);
                end;
            end;
            if Customer.Insert() then
                Customer.Modify();
        end;
        Message('Customers are Imported from XML file');
    end;
}