{*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.5                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2014                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*}
{strip}
{if $batchUpdate}
    {assign var='elementId'   value=$form.field.$elementIndex.$elementName.id}
    {assign var="tElement" value=$elementName|cat:"_time"}
    {assign var="timeElement" value=field_`$elementIndex`_`$elementName`_time}
    {$form.field.$elementIndex.$elementName.html}
{elseif $elementIndex}
    {assign var='elementId'   value=$form.$elementName.$elementIndex.id}
    {assign var="timeElement" value=$elementName|cat:"_time.$elementIndex"}
    {$form.$elementName.$elementIndex.html}
{elseif $blockId and $blockSection}
    {assign var='elementId'   value=$form.$blockSection.$blockId.$elementName.id}
    {assign var="tElement" value=`$elementName`_time}
    {$form.$blockSection.$blockId.$elementName.html}
    {assign var="timeElement" value=`$blockSection`_`$blockId`_`$elementName`_time}
    {if $tElement}
      &nbsp;&nbsp;{$form.$blockSection.$blockId.$tElement.label}
      &nbsp;&nbsp;{$form.$blockSection.$blockId.$tElement.html|crmAddClass:six}
    {/if}
{else}
    {if !$elementId}
      {assign var='elementId'   value=$form.$elementName.id}
    {/if}
    {assign var="timeElement" value=$elementName|cat:'_time'}
    {$form.$elementName.html}
{/if}

{assign var='displayDate' value=$elementId|cat:"_display"}

{if $action neq 1028}
    <input type="text" name="{$displayDate}" id="{$displayDate}" class="form-control dateplugin" autocomplete="off"/>
{/if}

{if $batchUpdate AND $timeElement AND $tElement}
    &nbsp;&nbsp;{$form.field.$elementIndex.$tElement.label}&nbsp;&nbsp;{$form.field.$elementIndex.$tElement.html|crmAddClass:six}
{elseif $timeElement AND !$tElement}
    {if $form.$timeElement.label}
      &nbsp;&nbsp;{$form.$timeElement.label}&nbsp;&nbsp;
    {/if}
    {$form.$timeElement.html|crmAddClass:six}
{/if}

{if $action neq 1028}
    <a href="#" class="crm-hover-button crm-clear-link" title="{ts}Clear{/ts}"><span class="icon close-icon"></span></a>
{/if}

<script type="text/javascript">
    {literal}
    CRM.$(function($) {
      {/literal}
      var element_date   = "#{$displayDate}";
      var element_time  = "#{$elementId}_time";
      {if $timeElement}
          element_time  = "#{$timeElement}";
          var time_format   = $( element_time ).attr('timeFormat');
          {literal}
              $(element_time).timeEntry({ show24Hours : time_format, spinnerImage: '' });
          {/literal}
      {/if}
      var currentYear = new Date().getFullYear();
      var alt_field   = '#{$elementId}';
      $( alt_field ).hide();
      var date_format = $( alt_field ).attr('format');

      var altDateFormat = 'mm/dd/yy';
      {literal}
      switch ( date_format ) {
        case 'dd-mm':
        case 'mm/dd':
            altDateFormat = 'mm/dd';
            break;
      }

      if ( !( ( date_format == 'M yy' ) || ( date_format == 'yy' ) || ( date_format == 'yy-mm' ) ) ) {
          $( element_date ).addClass( 'dpDate' );
      }

      {/literal}
      var yearRange   = currentYear - parseInt( $( alt_field ).attr('startOffset') );
          yearRange  += ':';
          yearRange  += currentYear + parseInt( $( alt_field ).attr('endOffset'  ) );
      {literal}

      var startRangeYr = currentYear - parseInt( $( alt_field ).attr('startOffset') );
      var endRangeYr = currentYear + parseInt( $( alt_field ).attr('endOffset'  ) );

      var lcMessage = {/literal}"{$config->lcMessages}"{literal};
      var localisation = lcMessage.split('_');
      var dateValue = $(alt_field).val( );
      $(element_date).datepicker({
                                    closeAtTop        : true,
                                    dateFormat        : date_format,
                                    changeMonth       : true,
                                    changeYear        : true,
                                    altField          : alt_field,
                                    altFormat         : altDateFormat,
                                    yearRange         : yearRange,
                                    regional          : localisation[0],
                                    minDate           : new Date(startRangeYr, 1 - 1, 1),
                                    maxDate           : new Date(endRangeYr, 12 - 1, 31)
                                });

      // set default value to display field, setDefault param for datepicker
      // is not working hence using below logic
      // parse the date
      var displayDateValue = $.datepicker.parseDate( altDateFormat, dateValue );

      // format date according to display field
      displayDateValue = $.datepicker.formatDate( date_format, displayDateValue );
      $( element_date).val( displayDateValue );
      //support unsaved-changes warning: CRM-14353
      $( element_date).data('crm-initial-value', displayDateValue);

      $(element_date).click( function( ) {
          hideYear( this );
      });
      $('.ui-datepicker-trigger').click( function( ) {
          hideYear( $(this).prev() );
      });
      function hideYear( element ) {
        var format = $( element ).attr('format');
        if ( format == 'dd-mm' || format == 'mm/dd' ) {
          $(".ui-datepicker-year").css('display', 'none');
        }
      }
      $(alt_field + ',' + element_date + ',' + element_time).on('blur change', function() {
        var vis = $(alt_field).val() || $(element_time).val() ? '' : 'hidden';
        $(this).siblings('.crm-clear-link').css('visibility', vis);
      });
      $(alt_field).change();
    });

    {/literal}
</script>
{/strip}
