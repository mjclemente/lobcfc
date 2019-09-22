/**
* lobcfc
* Copyright 2018  Matthew J. Clemente, John Berquist
* Licensed under MIT (https://mit-license.org)
*/
component accessors="true" {

  property name="description" default="";
  property name="to" default="";
  property name="from" default="";
  property name="front" default="";
  property name="back" default="";
  property name="merge_variables" default="";
  property name="size" default="";
  property name="mail_type" default="";
  property name="send_date" default="";
  property name="metadata" default="";

  /**
  * https://lob.com/docs#postcards_object
  * @hint No parameters can be passed to init this component. They must be built manually. When creating and updating postcards, the following fields are required:
    * to
    * front
    * back
  */
  public any function init() {
    setMerge_variables( {} );
    setMetadata( {} );
    return this;
  }

  /**
  * @hint An internal description that identifies this resource.
  */
  public any function description( required string description ) {
    setDescription( description );
    return this;
  }

  /**
  * @hint Required
  * @address Must either be an address ID or an inline object with correct address parameters.
  */
  public any function to( required any address ) {
    if ( isValid( 'component', address ) )
      var toAddress = address.build();
    else
      var toAddress = address;

    setTo( toAddress );
    return this;
  }

  /**
  * @address Must either be an address ID or an inline object with correct address parameters.
  */
  public any function from( required any address ) {
    if ( isValid( 'component', address ) )
      var fromAddress = address.build();
    else
      var fromAddress = address;

    setFrom( fromAddress );
    return this;
  }

  /**
  * @hint Required. The artwork to use as the front of your postcard. Accepts an HTML string of under 10,000 characters, the ID of a saved HTML template, or a remote URL or a local upload of an HTML, PDF, PNG, or JPG file.
  */
  public any function front( required string front ) {
    setFront( front );
    return this;
  }

  /**
  * @hint Required. The artwork to use as the back of your postcard. Accepts an HTML string of under 10,000 characters, the ID of a saved HTML template, or a remote URL or a local upload of an HTML, PDF, PNG, or JPG file.
  */
  public any function back( required string back ) {
    setBack( back );
    return this;
  }

  /**
  * @hint Variables can be defined in your HTML with double curly braces, e.g. {{variable_name}}. Use merge_variables to provide replacements for those variables to create custom content. merge_variables must be an object with up to 40 key-value pairs. Keys must be at most 40 characters and values must be at most 500 characters. Neither can contain the characters " and \. Nested objects are not supported. https://lob.com/resources/guides/general/using-html-and-merge-variables#merge-variable-strictness-setting for more information.
  * @metadata if a struct is provided, it will be serialized. Otherwise the string will be set as provided
  */
  public any function mergeVariables( required any mergeVariables ) {
    if ( isStruct( mergeVariables ) )
      setMerge_variables( serializeJSON( mergeVariables ) );
    else
      setMerge_variables( mergeVariables );
    return this;
  }

  public any function size( required string size ) {
    setSize( size );
    return this;
  }

  /**
  * @hint alias for setting size
  */
  public any function as4x6() {
    return this.size( '4x6' );
  }

  /**
  * @hint alias for setting size
  */
  public any function as6x9() {
    return this.size( '6x9' );
  }

  /**
  * @hint alias for setting size
  */
  public any function as6x11() {
    return this.size( '6x11' );
  }

  //Skipping mail_type for now

  /**
  * @hint A timestamp in ISO 8601 format which specifies a date after the current time and up to 90 days in the future to send the postcard off for production.
  */
  public any function sendDate( required date timeStamp, boolean convertToUTC = true ) {
    setSend_date( getUTCTimestamp( timeStamp, convertToUTC ) );

    return this;
  }

  /**
  * @hint Use metadata to store custom information for tagging and labeling back to your internal systems. Must be an object with up to 20 key-value pairs. Keys must at most 40 characters and values must be at most 500 characters. Neither can contain the characters " and \. Nested objects are not supported. See https://lob.com/docs/java#metadata for more information.
  * @metadata if a struct is provided, it will be serialized. Otherwise the string will be set as provided
  */
  public any function metadata( required any metadata ) {
    if ( isStruct( metadata ) )
      setMetadata( serializeJSON( metadata ) );
    else
      setMetadata( metadata );
    return this;
  }

  /**
  * @hint The zip code needs to be handled via a custom method, to force it to be passed as a string
  */
  public string function build() {

    var body = '';
    var properties = getPropertyValues();
    var count = properties.len();

    properties.each(
      function( property, index ) {
        body &= '"#property.key#": ' & serializeJSON( property.value ) & '#index NEQ count ? "," : ""#';
      }
    );

    return '{' & body & '}';
  }

  /**
  * @hint helper that forces object value serialization to strings. This is needed in some cases, where CF's loose typing causes problems
  */
  private string function serializeValuesAsString( required any data ) {
    var result = '';
    if ( isStruct( data ) ) {
      var serializedData = data.reduce(
        function( result, key, value ) {

          if ( result.len() ) result &= ',';

          return result & '"#key#": "#value#"';
        }, ''
      );
      result = '{' & serializedData & '}';
    } else if ( isNumeric( data ) ) {
      result = '"#data#"';
    } else if ( isArray( data ) ) {
      var serializedData = data.reduce(
        function( result, item, index ) {
          if ( result.len() ) result &= ',';

          return result & '"#item#"';
        }, ''
      );

      result = '[' & serializedData & ']';
    }

    return result;
  }

  /**
  * Based on https://www.bennadel.com/blog/2501-converting-coldfusion-date-time-values-into-iso-8601-time-strings.htm
  * @hint I take the given date/time object and return the string that reprsents the date/time using the ISO 8601 format standard. The returned value is always in the context of UTC and therefore uses the special UTC designator ("Z"). The function will implicitly convert your date/time object to UTC (as part of the formatting) unless you explicitly ask it not to.
  */
  string function getIsoTimeString( required date dateToConvert, boolean convertToUTC = true ) {
    if ( convertToUTC )
      dateToConvert = dateConvert( "local2utc", dateToConvert );
    return( dateFormat( dateToConvert, "yyyy-mm-dd" ) & "T" & timeFormat( dateToConvert, "HH:mm:ss" ) & "Z" );
  }

  /**
  * @hint converts the array of properties to an array of their keys/values, while filtering those that have not been set
  */
  private array function getPropertyValues() {

    var propertyValues = getProperties().map(
      function( item, index ) {
        return {
          "key" : item.name,
          "value" : getPropertyValue( item.name )
        };
      }
    );

    return propertyValues.filter(
      function( item, index ) {
        if ( isStruct( item.value ) )
          return !item.value.isEmpty();
        else
          return item.value.len();
      }
    );
  }

  private array function getProperties() {

    var metaData = getMetaData( this );
    var properties = [];

    for( var prop in metaData.properties ) {
      properties.append( prop );
    }

    return properties;
  }

  private any function getPropertyValue( string key ){
    var method = this["get#key#"];
    var value = method();
    return value;
  }
}