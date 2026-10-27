// Decompiled by Jad v1.5.8b. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.geocities.com/kpdus/jad.html
// Decompiler options: packimports(3)
// Source File Name:   ByteArrayDataSource.java
package com.etechlogix.distribution.utils;
import java.io.*;
import javax.activation.DataSource;

public class ByteArrayDataSource
    implements DataSource
{

    ByteArrayDataSource(InputStream inputstream, String s)
    {
        type = s;
        try
        {
            ByteArrayOutputStream bytearrayoutputstream = new ByteArrayOutputStream();
            int i;
            while((i = inputstream.read()) != -1)
                bytearrayoutputstream.write(i);
            data = bytearrayoutputstream.toByteArray();
        }
        catch(IOException ioexception) { }
    }

    ByteArrayDataSource(byte abyte0[], String s)
    {
        data = abyte0;
        type = s;
    }

    ByteArrayDataSource(String s, String s1)
    {
        try
        {
            data = s.getBytes("iso-8859-1");
        }
        catch(UnsupportedEncodingException unsupportedencodingexception) { }
        type = s1;
    }

    public InputStream getInputStream()
        throws IOException
    {
        if(data == null)
            throw new IOException("no data");
        else
            return new ByteArrayInputStream(data);
    }

    public OutputStream getOutputStream()
        throws IOException
    {
        throw new IOException("cannot do this");
    }

    public String getContentType()
    {
        return type;
    }

    public String getName()
    {
        return "dummy";
    }

    private byte data[];
    private String type;
}
